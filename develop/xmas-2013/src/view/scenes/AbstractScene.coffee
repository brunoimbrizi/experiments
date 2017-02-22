class AbstractScene

	ctx 					: null
	audio 					: null

	index					: null
	name					: ''
	speed 					: null

	reindeer 				: null


	constructor: (@ctx, @index) ->
		@audio = app.audio
		@speed = 18.62

		@initReindeer()


	start: ->
		if (!@audio.sourceNode) then return
		@audio.sourceNode.playbackRate.value = 1
		@speed = 18.62


	update: ->
		if (!@audio.startedAt) then return
		if (@audio.paused) then return

		# dance!
		dt = Date.now() - @audio.startedAt
		frame = ((dt / @speed) >> 0) % 58
		# frame = ((dt / (app.view.ui.drawSpeed * 0.1)) >> 0) % 58

		for a in @reindeer.anchors
			a.pos = a.positions[frame]


	initReindeer: ->
		@reindeer = new ReindeerAnchors()
		# @timelines = []

		# dance!
		for a in @reindeer.anchors
			a.pos = a.positions[0]

			# timeline = new TimelineMax({ repeat:-1, paused:true })
			# @timelines.push(timeline)
			# for p in a.positions
				# timeline.add(TweenLite.to(a.pos, 0.04, { x:p.x, y:p.y, ease:Linear.easeOut}))
		