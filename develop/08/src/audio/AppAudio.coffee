class AppAudio

	ctx 					: null
	loaded					: null
	paused					: null
	ended					: null

	startedAt				: null
	pausedAt				: null

	duration 				: null
	currentTime 			: null
	playbackRate 			: 1

	sourceNode				: null
	analyserNode			: null
	buffer 					: null

	values					: null

	FFT_SIZE				: 2048
	BINS					: 256

	@EVENT_AUDIO_ENDED 		: 'audioEnded'
	@EVENT_AUDIO_RESTARTED	: 'audioRestarted'

	@SOUND_TEEN_SPIRIT 		: 'sound/teen-spirit.mp3'


	init: ->
		@ctx = new AudioContext()

		@values = []
		@duration = @currentTime = 0

		@analyserNode = @ctx.createAnalyser()
		@analyserNode.smoothingTimeConstant = 0.9
		@analyserNode.fftSize = @FFT_SIZE
		@analyserNode.connect(@ctx.destination) # comment out to start mute

		# @load('sound/wagner-short.ogg')
		# @load('sound/Fatbros.ogg')
		# @load('sound/IO-5.0.mp3')
		# @load('sound/02 - One Inch Man.mp3')
		# @load('sound/173363917_audio.mp3')
		# @load('sound/brant bjork - 08 - somewhere some woman.mp3')
		# @load('sound/A Perfect Circle-Pet.mp3')
		# @load('sound/04 God Hates A Coward.mp3')
		@load('sound/teen-spirit.mp3')
		

	update: ->
		freqData = new Uint8Array(@analyserNode.frequencyBinCount)
		@analyserNode.getByteFrequencyData(freqData)
		length = freqData.length

		bin = Math.ceil(length / @BINS)
		for i in [0...@BINS]
			sum = 0
			for j in [0...bin]
				sum += freqData[(i * bin) + j]

			# Calculate the average frequency of the samples in the bin
			average = sum / bin

			# Divide by 256 to normalize
			@values[i] = (average / 256) / @playbackRate


		# set current time
		if (@loaded && !@ended) 
			@currentTime = if (@paused) then @pausedAt else Date.now() - @startedAt
			@currentTime *= @playbackRate

		return

		
	load: (url) ->
		request = new XMLHttpRequest()
		request.open('GET', url, true)
		request.responseType = 'arraybuffer'
		request.onprogress = @onRequestProgress
		request.onload = @onRequestLoad
		request.send()


	play: ->
		if (@ended) then window.dispatchEvent(new Event(AppAudio.EVENT_AUDIO_RESTARTED))

		@sourceNode = @ctx.createBufferSource()
		@sourceNode.onended = @onSourceEnded
		@sourceNode.connect(@analyserNode)
		@sourceNode.playbackRate.value = @playbackRate
		@sourceNode.buffer = @buffer
		@ended = false
		@paused = false

		if (@pausedAt)
			@startedAt = Date.now() - @pausedAt
			@sourceNode.start(0, @pausedAt / 1000)
		else
			@startedAt = Date.now()
			@sourceNode.start(0)


	stop: ->
		@sourceNode.stop(0)
		@pausedAt = Date.now() - @startedAt
		@paused = true


	seek: (time) ->
		if (time == undefined) then return
		if (time > @buffer.duration) then return

		@ended = false

		if (!@paused)
			@sourceNode.onended = null
			@sourceNode.stop(0)
		@pausedAt = time * 1000
		if (!@paused) then @play()


	onRequestProgress: (e) =>
		# console.log('AppAudio.onRequestProgress', e, app.view.ui)
		if (app.view.ui) then app.view.ui.loader.onLoadProgress(e)

		return


	onRequestLoad: (e) =>
		# console.log('AppAudio.onRequestLoad', e)
		if (app.view.ui) then app.view.ui.loader.onLoadComplete(e)

		@ctx.decodeAudioData(e.target.response, @onBufferLoaded, @onBufferError)

		return


	onBufferLoaded: (@buffer) =>
		app.view.ui.loader.onDecodeComplete()
		app.view.ui.player.show()

		_gaq.push(['_trackEvent', 'state', 'audio-decoded'])

		@loaded = true
		@duration = @buffer.duration * 1000 * @playbackRate
		@play()


	onBufferError: (e) ->
		# console.log('AppAudio.onBufferError', e)
		app.view.ui.loader.onError(e)


	onSourceEnded: (e) =>
		# console.log('AppAudio.onSourceEnded', @paused)
		if (@paused) then return
		@currentTime = @duration
		@ended = true
		@paused = true
		@pausedAt = 0

		window.dispatchEvent(new Event(AppAudio.EVENT_AUDIO_ENDED))