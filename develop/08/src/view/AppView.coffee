class AppView

	audio					: null

	renderer 				: null
	sketch 					: null
	three 					: null
	ui 						: null

	down					: false


	init: ->
		@audio = app.audio
		@timeline = app.timeline
		@renderer = new THREE.WebGLRenderer({ antialias:true })

		@initSketch()
		TweenMax.globalTimeScale(@audio.playbackRate)


	initSketch: =>
		@sketch = Sketch.create
			type			: Sketch.WEBGL
			element 		: @renderer.domElement
			context 		: @renderer.context
			autopause 		: false


		@sketch.setup = =>
			@initThree()
			@initUI()
			@timeline.init()
			# @audio.load(AppAudio.SOUND_TEEN_SPIRIT)
				

		@sketch.update = =>
			# @ui.stats.begin()
			@audio.update()
			@three.update()
			@ui.update()
			@timeline.update()
			# @ui.stats.end()
			

		@sketch.draw = =>
			@three.draw()
			@ui.draw()


		@sketch.resize = =>
			if (!@three) then return
			@three.resize()
			@ui.resize()


		@sketch.touchstart = =>
			@down = true
			@ui.touchstart()
			# @three.touchstart()


		@sketch.touchmove = =>
			@ui.touchmove()
			if (!@down) then return
			# @three.touchmove()


		@sketch.touchend = =>
			@down = false
			# @three.touchend()


		@sketch.keyup = (e) =>
			# space
			if (e.keyCode == 32)
				if (!@audio.paused) 
					@audio.stop()
					@pause()
				else
					@audio.play()
					@resume()


	initThree: =>
		@three = new AppThree()


	initUI: =>
		@ui = new AppUI()


	pause: =>
		TweenMax.pauseAll()
		@three.controls.enabled = true

	resume: =>
		TweenMax.resumeAll()
		@three.controls.enabled = false