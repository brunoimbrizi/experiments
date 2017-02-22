class AppUI

	view 					: null
	audio 					: null
	
	stats					: null

	info 					: null
	more 					: null
	infoOpen 				: false
	loader 					: null
	outro 					: null

	drawAnchors				: true
	drawLines				: true
	drawSpeed				: null

	mute 					: true
	playbackRate			: null


	constructor: ->
		@view = app.view
		@audio = app.audio
		@drawSpeed = 186
		@playbackRate = 1.0

		@initLoader()
		@initInfo()
		# @initStats()
		# @initGUI()


	initLoader: ->
		@loader = document.getElementById('loader')


	initInfo: ->
		@info = document.getElementById('info')
		@more = document.getElementById('more')
		@more.addEventListener('click', @onMoreClick)
		@moreIcon = document.getElementById('moreIcon')


	initStats: ->
		@stats = new Stats()
		@stats.domElement.style.position = 'absolute'
		@stats.domElement.style.left = '0px'
		@stats.domElement.style.top = '0px'

		document.body.appendChild( @stats.domElement )

		setInterval( =>
				@stats.begin()
				@stats.end()
		, 1000 / 60 )


	initGUI: ->
		gui = new dat.GUI()
		gui.close()
		that = @

		f1 = gui.addFolder('Draw')
		f1.open()
		f1.add(@, 'drawAnchors')
		f1.add(@, 'drawLines')
		f1.add(@, 'drawSpeed', 150, 240)

		f2 = gui.addFolder('Audio')
		f2.open()
		f2.add(@, 'mute').onChange(-> that.onMuteChange()).listen()
		f2.add(@, 'playbackRate', 0.0, 1.0, 0.1).onChange(-> that.onPlaybackRateChange())


	showOutro: ->
		@outro = document.getElementById('outro')
		@outro.style.display = 'block'


	onMuteChange: ->
		if (@mute) then	@audio.analyserNode.disconnect()
		else @audio.analyserNode.connect(@audio.ctx.destination)


	onPlaybackRateChange: ->
		@audio.sourceNode.playbackRate.value = @playbackRate


	onMoreClick: =>
		if (!@infoOpen)
			TweenMax.to(@more, 0.5, { css:{ left:0 }, ease:Quart.easeInOut } )
			TweenMax.to(@info, 0.5, { css:{ left:0 }, ease:Quart.easeInOut } )
			@moreIcon.innerHtml = '-'
		else
			TweenMax.to(@more, 0.5, { css:{ left:-280 }, ease:Quart.easeInOut } )
			TweenMax.to(@info, 0.5, { css:{ left:-330 }, ease:Quart.easeInOut } )
			@moreIcon.innerHtml = '+'
		@infoOpen = !@infoOpen


	onAudioLoaded: =>
		@loader.style.display = 'none'