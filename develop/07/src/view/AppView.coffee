class AppView extends Backbone.View

	sketch 					: null
	three 					: null
	ui 						: null

	showed 					: null
	lines					: null

	audio 					: null

	el 						: '#container'


	init: ->
		@initSketch()
		@initThree()
		@initUI()
		@initAudio()


	initSketch: ->
		@sketch = Sketch.create

			container		: document.getElementById 'container'
			type			: Sketch.WEB_GL

			setup: =>
				

			update: =>
				@three.update()
				@ui.update()


			draw: =>
				@three.draw()
				@ui.draw()


			resize: =>
				if (!@three) then return
				@three.resize()
				@ui.resize()


			mousedown: (e) =>
				if (!@showed)
					TweenLite.killTweensOf(@three.camera.position)
					TweenLite.killTweensOf(@three.camera.up)
					@showed = true
				@three.mousedown(e)


			mousemove: (e) =>
				@three.mousemove(e)


			mouseup: (e) =>
				@three.mouseup(e)


			keyup: (e) =>
				@ui.keyup(e)



	initThree: =>
		@three = new AppThree()
		@lines = @three.lines


	initUI: =>
		@ui = new AppUI()


	initAudio: =>
		@audio = document.getElementById('audio')


	show: (delay = 0) =>
		##
		# TweenLite.to(@three.camera.position, 2, { x:-150, y:-295, z:30, delay:delay, ease:Quart.easeInOut } )
		TweenLite.to(@three.camera.position, 2, { x:-57, y:-82, z:12, delay:delay, ease:Expo.easeInOut, onComplete: =>
			@showed = true
			# nextSprite = @lines[1].getSprite('OXC')
			# @ui.toggleLabel(nextSprite)
		} )
		# TweenLite.to(@three.camera.rotation, 3, { x:1.43, y:-0.64, z:-0.22, delay:delay, ease:Quart.easeOut } )
		TweenLite.to(@three.camera.up, 2, { x:0.18, y:0.00, z:0.98, delay:delay, ease:Quart.easeInOut } )
		##

		@audio.muted = false
		@audio.volume = 0

		obj = { volume: 0 }
		TweenLite.to(@audio, 3, { volume: 0.4, delay:delay + 2, ease:Linear.easeNone } )