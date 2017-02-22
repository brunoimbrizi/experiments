class PlayerView

	view					: null
	audio 					: null

	ctx 					: null

	pos 					: null
	totalWidth				: null
	alpha 					: null
	showAlpha 				: null

	over 					: null
	showed 					: null

	@BAR_WIDTH 				: 320


	constructor: (@ctx) ->
		@view = app.view
		@audio = app.audio
		
		@alpha = 0.0
		@showAlpha = 0.0
		@over = false
		@totalWidth = 0


	show: =>
		@showed = true

		TweenLite.to(@, 0.5, { totalWidth:PlayerView.BAR_WIDTH, delay:0.4, ease:Expo.easeInOut })
		TweenLite.to(@, 0.3, { alpha:0.2 })
		TweenLite.to(@, 0.3, { showAlpha:0.2, delay:0.3 })


	update: ->
		if (!@audio.sourceNode) then return


	draw: ->
		@pos = { x:(@view.sketch.width - PlayerView.BAR_WIDTH) * .5, y:@view.sketch.height - 65 }

		@ctx.translate(@pos.x, @pos.y)

		# total bar
		@ctx.beginPath()
		@ctx.rect(0, 0, @totalWidth, 1)
		@ctx.fillStyle = 'rgba(255, 255, 255, 0.2)'
		@ctx.fill()
		@ctx.closePath()

		# pause
		if (!@audio.paused)
			@ctx.beginPath()
			@ctx.rect(-24, -5, 2, 10)
			@ctx.rect(-19, -5, 2, 10)
			@ctx.fillStyle = 'rgba(255, 255, 255, ' + @alpha + ')'
			@ctx.fill()
			@ctx.closePath()

		# play
		else
			@ctx.beginPath()
			@ctx.moveTo(-24, -4)
			@ctx.lineTo(-16, 0)
			@ctx.lineTo(-24, 4)
			@ctx.lineTo(-24, -4)
			@ctx.fillStyle = 'rgba(255, 255, 255, ' + @alpha + ')'
			@ctx.fill()
			@ctx.closePath()

		# current bar
		if (@audio.duration)
			@ctx.beginPath()
			@ctx.rect(0, -1, (@audio.currentTime / @audio.duration) * @totalWidth, 2)
			@ctx.fillStyle = 'rgba(255, 255, 255, 0.2)'
			@ctx.fill()
			@ctx.closePath()

		# time
		@ctx.fillStyle = 'rgba(255, 255, 255, ' + @showAlpha + ')'
		@ctx.font = '12px Monda'
		@ctx.fillText(StringUtils.formatTime(@audio.currentTime, false), PlayerView.BAR_WIDTH + 15, 4)


		@ctx.setTransform(1, 0, 0, 1, 0, 0)

		return


	touchstart: =>
		if (!@showed) then return

		if (@over)
			if (!@audio.paused) 
				@audio.stop()
				@view.pause()
			else
				@audio.play()
				@view.resume()


	touchmove: =>
		if (!@showed) then return

		touch = @view.sketch.touches[0]

		if (touch.x > @pos.x - 50 && touch.x < @pos.x + 10 && touch.y > @pos.y - 30 && touch.y < @view.sketch.height)
			@alpha = 1
			@over = true
		else
			@alpha = 0.2
			@over = false

