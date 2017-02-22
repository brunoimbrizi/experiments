class AppView

	audio					: null

	sketch 					: null
	ui 						: null

	scenes					: null


	init: ->
		@audio = app.audio

		@initSketch()
		@initUI()
		@initScenes()


	initSketch: ->
		@sketch = Sketch.create

			container		: document.getElementById('container')
			type			: Sketch.CANVAS
			# autoclear 		: false

		@sketch.setup = =>
			@sketch.canvas.onselectstart = -> return false
				

		@sketch.update = =>
			@audio.update()
			@scenes.update()
				

		@sketch.draw = =>
			@scenes.draw()
			

		@sketch.resize = =>



		@sketch.mousedown = =>
			@sketch.down = true
			# @draw.mousedown()


		@sketch.mouseup = =>
			@sketch.down = false
			# @draw.mouseup()


		@sketch.mousemove = =>
			if (!@draw) then return
			# @draw.mousemove()


		@sketch.keyup = (e) =>
			# left
			if (e.keyCode == 37)
				@scenes.auto = false
				@scenes.prev()
			# right
			if (e.keyCode == 39)
				@scenes.auto = false
				@scenes.next()
			# space
			if (e.keyCode == 32)
				if (!@audio.paused) then @audio.stop()
				else @audio.play()
			# m
			if (e.keyCode == 77)
				@ui.mute = !@ui.mute
				@ui.onMuteChange()



	initUI: =>
		@ui = new AppUI()


	initScenes: =>
		@scenes = new Scenes(@sketch)