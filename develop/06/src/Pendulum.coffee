class Pendulum

	ctx 				: null
	trigger				: null

	index				: null
	pos 				: null
	oldY				: null
	radius 				: null
	color				: null
	delay				: null
	freq				: null
	oldFreq				: null
	direction			: null

	AMPLITUDE			: 100

	constructor: (@ctx, @index, @pos, @freq, @delay, @trigger) ->
		@color = 'rgb(200, 200, 200)'
		@radius = 4.0


	update: (time) ->
		if time < @delay then return

		@pos.y = sin(@freq * (time - @delay) * TWO_PI) * @AMPLITUDE

		# 0 = up, 1 = down
		@direction = @pos.y > @oldY

		# if pos.y crossed the middle
		if (@freq == @oldFreq && @oldY * @pos.y < 0)
			@trigger.fire()

		@oldY = @pos.y
		@oldFreq = @freq


	draw: ->
		@ctx.translate(@pos.x, @pos.y)

		@ctx.beginPath()
		@ctx.arc(0, 0, @radius, 0, TWO_PI)
		@ctx.fillStyle = @color
		@ctx.fill()
		@ctx.closePath()

		@ctx.setTransform(1, 0, 0, 1, 0, 0)