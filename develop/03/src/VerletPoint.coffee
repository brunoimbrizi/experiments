class VerletPoint

	x				: null
	y				: null
	ox				: null
	oy				: null
	fixed			: false

	mass			: 1
	# invmass
	w				: 1

	constructor: (x, y) ->
		@setPosition(x, y)


	setPosition: (x, y) ->
		@x = @ox = x
		@y = @oy = y


	update: ->
		if (@fixed) then return

		x = @x
		y = @y

		@x += @getVx()
		@y += @getVy()

		@ox = x
		@oy = y


	draw: (ctx, radius = 1, color = '#ffffff') ->
		ctx.arc(@x, @y, radius, 0, TWO_PI)


	getVx: ->
		@x - @ox


	setVx: (vx) ->
		@ox = @x - vx


	getVy: ->
		@y - @oy


	setVy: (vy) ->
		@oy = @y - vy


	setFixed: (value) ->
		@fixed = value

		if (value) then @w = 0.0000001
		else @w = 1 / @mass