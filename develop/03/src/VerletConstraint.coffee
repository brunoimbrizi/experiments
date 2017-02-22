class VerletConstraint

	pointA			: null
	pointB			: null
	length			: null


	constructor: (@pointA, @pointB, @length = -1) ->
		if (length == -1)
			dx = pointA.x - pointB.x
			dy = pointA.y - pointB.y
			@length = sqrt(dx * dx + dy * dy)


	update: ->
		dx = @pointB.x - @pointA.x
		dy = @pointB.y - @pointA.y
		dd = sqrt(dx * dx + dy * dy)
		diff = (@length - dd) / (dd * (@pointA.w + @pointB.w))

		@pointA.x -= @pointA.w * dx * diff
		@pointA.y -= @pointA.w * dy * diff
		@pointB.x += @pointB.w * dx * diff
		@pointB.y += @pointB.w * dy * diff


	draw: (ctx, color = '#ffffff') ->
		ctx.moveTo(@pointA.x, @pointA.y)
		ctx.lineTo(@pointB.x, @pointB.y)
