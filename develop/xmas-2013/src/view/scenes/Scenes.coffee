class Scenes

	audio 					: null

	ctx 					: null
	scenes 					: null
	current					: null

	playingIntro			: null
	playingOutro			: null
	auto 					: null
	lastChange 				: 0


	constructor: (@ctx) ->
		@audio = app.audio
		@initScenes()
		@goto(0)

		@playingIntro = true
		@auto = true


	update: ->
		@scenes[@current].update()

		if (!@audio.startedAt) then return
		if (@audio.paused) then return
		if (@playingIntro) then return
		if (!@auto) then return
		
		dt = Date.now() - @audio.startedAt

		# music is over
		if (dt > 222000 && !@playingOutro)
			@showOutro()
			return

		if ((dt - @lastChange) * @audio.sourceNode.playbackRate.value > 4320)
			@lastChange = dt
			@next()
			@scenes[@current].update()


	draw: ->
		@scenes[@current].draw()


	goto: (index) ->
		if (@playingIntro) then return

		@current = index
		@scenes[@current].start()


	prev: ->
		if (@current > 0) then @goto(@current - 1)
		else @goto(@scenes.length - 1)


	next: ->
		if (@current < @scenes.length - 1) then @goto(@current + 1)
		else @goto(0)


	killIntro: ->
		@lastChange = 9630
		# @lastChange = Date.now() - @audio.startedAt
		@playingIntro = false
		@scenes.shift()
		@goto(0)


	showOutro: ->
		@playingOutro = true
		app.view.ui.showOutro()


	initScenes: ->
		@scenes = []
		@scenes.push(new SceneIntro(@ctx, @scenes.length))
		@scenes.push(new SceneBasic(@ctx, @scenes.length))
		@scenes.push(new SceneCircles(@ctx, @scenes.length))
		@scenes.push(new SceneRays(@ctx, @scenes.length))
		@scenes.push(new SceneRopeBall(@ctx, @scenes.length))
		@scenes.push(new SceneFatso(@ctx, @scenes.length))
		@scenes.push(new SceneChewbacca(@ctx, @scenes.length))