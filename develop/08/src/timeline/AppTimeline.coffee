class AppTimeline

	view 					: null
	audio					: null

	currentTime 			: null
	timeline 				: null


	init: ->
		@view = app.view
		@audio = app.audio

		@initTimeline()

		window.addEventListener(AppAudio.EVENT_AUDIO_ENDED, @onAudioEnded)
		window.addEventListener(AppAudio.EVENT_AUDIO_RESTARTED, @onAudioRestarted)


	initTimeline: ->
		@currentTime = 0
		@timeline = []

		@add(26800,		@view.three.bars,	@view.three.bars.setState,		1)
		@add(36500,		@view.three.bars,	@view.three.bars.setState,		2)
		@add(67000,		@view.three.bars,	@view.three.bars.setState,		3)
		@add(100000,	@view.three.bars,	@view.three.bars.setState,		4)
		@add(116000,	@view.three.bars,	@view.three.bars.setState,		5)
		@add(145500,	@view.three.bars,	@view.three.bars.setState,		6)
		@add(177000,	@view.three.bars,	@view.three.bars.setState,		7)
		@add(203000,	@view.three.bars,	@view.three.bars.setState,		8)
		@add(220500,	@view.three.bars,	@view.three.bars.setState,		9)

		@add(115000,	@view.three.lyrics,	@view.three.lyrics.setState,	0)
		@add(117000,	@view.three.lyrics,	@view.three.lyrics.setState,	1)
		@add(119000,	@view.three.lyrics,	@view.three.lyrics.setState,	2)
		@add(137000,	@view.three.lyrics,	@view.three.lyrics.setState,	3)
		@add(166000,	@view.three.lyrics,	@view.three.lyrics.setState,	4)
		@add(167000,	@view.three.lyrics,	@view.three.lyrics.setState,	5)

		@add(6000,		@view.three,		@view.three.setState,	0)
		@add(20000,		@view.three,		@view.three.setState,	1)
		@add(36500,		@view.three,		@view.three.setState,	2)
		@add(45000,		@view.three,		@view.three.setState,	3)
		@add(50000,		@view.three,		@view.three.setState,	4)
		@add(60000,		@view.three,		@view.three.setState,	5)
		@add(66000,		@view.three,		@view.three.setState,	6)
		@add(71000,		@view.three,		@view.three.setState,	7)
		@add(80000,		@view.three,		@view.three.setState,	8)
		@add(90000,		@view.three,		@view.three.setState,	9)
		@add(100000,	@view.three,		@view.three.setState,	10)
		@add(112000,	@view.three,		@view.three.setState,	11)
		@add(120000,	@view.three,		@view.three.setState,	12)
		@add(127000,	@view.three,		@view.three.setState,	13)
		@add(135000,	@view.three,		@view.three.setState,	14)
		@add(145000,	@view.three,		@view.three.setState,	15)
		@add(167000,	@view.three,		@view.three.setState,	16)
		@add(170000,	@view.three,		@view.three.setState,	17)
		@add(178000,	@view.three,		@view.three.setState,	18)
		@add(190000,	@view.three,		@view.three.setState,	19)
		@add(203000,	@view.three,		@view.three.setState,	20)
		@add(205000,	@view.three,		@view.three.setState,	21)
		@add(220500,	@view.three,		@view.three.setState,	22)
		@add(235000,	@view.three,		@view.three.setState,	23)



	add: (delay, caller, callback, params = null) ->
		if (params != null && typeof params != 'object') then params = [params]
		@timeline.push({ caller: caller, callback: callback, params: params, delay: delay })
		@timeline = _.sortBy(@timeline, 'delay')

		return


	update: ->
		@currentTime = @audio.currentTime

		clear = 0

		for t in @timeline
			# trigger callback if it is time
			if (t.delay <= @currentTime)
				t.callback.apply(t.caller, t.params)
				clear++
				continue
			# stop the loop if earliest delay is bigger than current time
			else break

		for i in [0...clear]
			@timeline.shift()

		return


	onAudioEnded: (e) =>
		# console.log 'Timeline.onAudioEnded', e
		_gaq.push(['_trackEvent', 'state', 'end'])

		return


	onAudioRestarted: (e) =>
		# console.log 'Timeline.onAudioRestarted', e
		_gaq.push(['_trackEvent', 'state', 'restart'])
		@initTimeline()

		return