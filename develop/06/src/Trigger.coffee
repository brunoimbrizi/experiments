class Trigger

	ctxCanvas			: null
	ctxAudio			: null

	index				: null
	type				: null
	pos					: null
	radius				: null
	color				: null
	fired				: null

	blast				: null
	hover				: null

	buffer				: null
	sound 				: null
	pitch				: null

	gain 				: null
	wetGain				: null
	flange 				: null

	over 				: null

	@TYPE_OFF			: 0
	@TYPE_SHAKER		: 1
	@TYPE_HIHAT			: 2
	@TYPE_KICK			: 3
	@TYPE_BLOCK			: 4
	@TYPE_CLAP			: 5

	SOUND_SHAKER		: 'shaker'
	SOUND_HIHAT			: 'hihat'
	SOUND_KICK			: 'kick'
	SOUND_BLOCK			: 'block'
	SOUND_CLAP			: 'clap'

	@HIT_RADIUS_SQ		: 100


	constructor: (@ctxCanvas, @ctxAudio, @gain, @index, @pos, @type, @pitch) ->
		@radius = 2
		@color = 'rgb(40, 40, 40)'
		@fired = false

		@blast = 
			radius: 3
			alpha: 1
			lineWidth: 1
			color: null

		@hover =
			radius: 0

		@loadSound(@type)


	update: ->


	draw: ->
		@ctxCanvas.translate(@pos.x, @pos.y)

		# hover
		@ctxCanvas.beginPath()
		@ctxCanvas.arc(0, 0, @hover.radius, 0, TWO_PI)
		@ctxCanvas.fillStyle = 'rgba(' + @blast.color + ', 0.8)'
		@ctxCanvas.fill()
		@ctxCanvas.closePath()

		# blast
		@ctxCanvas.beginPath()
		@ctxCanvas.arc(0, 0, @blast.radius, 0, TWO_PI)
		@ctxCanvas.lineWidth = @blast.lineWidth
		@ctxCanvas.strokeStyle = 'rgba(' + @blast.color + ',' + @blast.alpha + ')'
		@ctxCanvas.stroke()
		@ctxCanvas.closePath()

		# trigger
		@ctxCanvas.beginPath()
		@ctxCanvas.arc(0, 0, @radius, 0, TWO_PI)
		@ctxCanvas.fillStyle = @color
		@ctxCanvas.fill()
		@ctxCanvas.closePath()

		@ctxCanvas.setTransform(1, 0, 0, 1, 0, 0)


	mousedown: ->
		if @type < 5 then @loadSound(@type + 1)
		else @loadSound(0)


	mouseover: ->
		if @over then return
		@over = true
		TweenLite.to(@hover, 0.2, { radius:12, ease:Quart.easeOut } )


	mouseout: ->
		if !@over then return
		@over = false
		TweenLite.to(@hover, 0.2, { radius:0, ease:Quart.easeOut } )


	fire: ->
		if !@type then return

		@fired = true
		@blast.radius = 4
		@blast.alpha = 0.8
		# TweenLite.to(@blast, 0.5, { alpha:0, overwrite:1, ease:Expo.easeOut })
		# TweenLite.to(@blast, 1, { radius:30, overwrite:2, ease:Expo.easeOut })

		TweenLite.to(@blast, 0.1, { radius:15, alpha:1, lineWidth:15, ease:Linear.easeOut, onComplete: =>
			TweenLite.to(@blast, 0.5, { radius:3, lineWidth:1, ease:Quart.easeOut })
		})

		@playSound()


	loadSound: (@type) ->
		switch @type
			when Trigger.TYPE_OFF
				@sound = null
				@blast.color = '50, 50, 50'
			when Trigger.TYPE_SHAKER
				@sound = @SOUND_SHAKER
				@blast.color = '50, 200, 220'
			when Trigger.TYPE_HIHAT
				@sound = @SOUND_HIHAT
				@blast.color = '25, 100, 140'
			when Trigger.TYPE_KICK
				@sound = @SOUND_KICK
				@blast.color = '140, 25, 55'
			when Trigger.TYPE_BLOCK
				@sound = @SOUND_BLOCK
				@blast.color = '165, 165, 50'
			when Trigger.TYPE_CLAP
				@sound = @SOUND_CLAP
				@blast.color = '80, 155, 45'

		if !@ctxAudio then return
		if !@sound then return

		url = 'sounds/' + @sound + '.ogg'
		request = new XMLHttpRequest()
		request.open('GET', url, true)
		request.responseType = 'arraybuffer'

		request.onload = =>
			# request.response === encoded... so decode it now
			@ctxAudio.decodeAudioData(request.response, (buffer) =>
				@buffer = buffer
			)

		request.send()

		###
		# create mix gain nodes
		audioContext = @ctxAudio
		outputMix = audioContext.createGainNode()
		dryGain = audioContext.createGainNode()
		wetGain = audioContext.createGainNode()
		effectInput = audioContext.createGainNode()
		# audioInput.connect(dryGain)
		# audioInput.connect(effectInput)
		dryGain.connect(outputMix)
		wetGain.connect(outputMix)
		outputMix.connect( audioContext.destination)

		@wetGain = wetGain
		@flange = @initFlange()
		@flange.connect(@ctxAudio.destination)
		###


	playSound: ->
		if !@ctxAudio then return
		if !@buffer then return

		source = @ctxAudio.createBufferSource()
		source.buffer = @buffer
		# source.connect(@ctxAudio.destination)
		# source.connect(@flange)
		source.connect(@gain)
		source.playbackRate.value = @pitch
		source.start(0)

	###
	initFlange: ->
		delayNode = @ctxAudio.createDelayNode()
		delayNode.delayTime.value = 0.005
		fldelay = delayNode

		inputNode = @ctxAudio.createGainNode()
		feedback = @ctxAudio.createGainNode()
		osc = @ctxAudio.createOscillator()
		gain = @ctxAudio.createGainNode()
		gain.gain.value = 0.002
		fldepth = gain

		feedback.gain.value = 0.5
		flfb = feedback

		osc.type = osc.SINE
		osc.frequency.value = 0.25
		flspeed = osc

		osc.connect(gain)
		gain.connect(delayNode.delayTime)

		inputNode.connect( @wetGain )
		inputNode.connect( delayNode )
		delayNode.connect( @wetGain )
		delayNode.connect( feedback )
		feedback.connect( inputNode )

		osc.noteOn(0)

		return inputNode
	###