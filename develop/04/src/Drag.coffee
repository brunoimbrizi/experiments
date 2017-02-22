class Drag

	ctx 				: null
	pos 				: null
	radius				: null
	lineWidth			: null
	alpha 				: null
	down				: false
	over				: false

	RADIUS 				: 5
	
	@HIT_RADIUS_SQ		: 81


	constructor: (ctx, pos) ->
		@ctx = ctx
		@pos = pos
		@radius = @RADIUS + 1
		@alpha = 1
		@lineWidth = 3


	render: ->
		@ctx.beginPath()
		# @ctx.fillStyle = 'rgba(200, 200, 200, ' + @alpha + ')'
		@ctx.strokeStyle = 'rgba(255, 255, 255, ' + @alpha + ')'
		@ctx.lineWidth = @lineWidth
		@ctx.arc(@pos.x, @pos.y, @radius, 0, TWO_PI)
		# @ctx.fill()
		@ctx.stroke()
		@ctx.closePath()


	mousedown: ->
		@down = true


	mousemove: ->
		@pos.x = @ctx.mouse.x
		@pos.y = @ctx.mouse.y


	mouseup: ->
		@down = false


	mouseover: ->
		@over = true
		@radius = @RADIUS + 1
		@alpha = 1
		@lineWidth = 3


	mouseout: ->
		@over = false
		@radius = @RADIUS
		@alpha = 0.6
		@lineWidth = 2