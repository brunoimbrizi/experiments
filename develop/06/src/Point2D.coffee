class Point2D

	x					: null
	y					: null

	constructor: (x, y) ->
		@x = x
		@y = y


	distanceTo: (p) ->
		dx = @x - p.x
		dy = @y - p.y
		sqrt(dx * dx + dy * dy)