class SceneBasic extends AbstractScene

	count 					: 0
	color 					: null
	colors 					: null


	constructor: (@ctx, @index) ->
		super

		@initColors()


	start: ->
		@color = @colors[@count % @colors.length]
		@count++

		super


	draw: ->
		hw = @ctx.width * .5
		hh = @ctx.height * .5
		scale = 1

		###
		@ctx.fillStyle = 'rgba(240, 110, 170, 0.4)'
		@ctx.beginPath()
		for a in @reindeer.anchors
			@ctx.lineTo(a.pos.x + hw + 10, a.pos.y + hh + 4)
		@ctx.fill()
		@ctx.closePath()
		###

		@ctx.globalCompositeOperation = 'source-over'


		@ctx.fillStyle = '#cccccc'
		@ctx.beginPath()
		for a in @reindeer.anchors
			@ctx.lineTo(a.pos.x + hw, a.pos.y + hh)
		@ctx.fill()
		@ctx.closePath()


		if (@count == 1) then return
		
		# @ctx.strokeStyle = @color
		@ctx.fillStyle = @color
		@ctx.beginPath()
		for a in @reindeer.anchors
			@ctx.lineTo(a.pos.x + hw - 10, a.pos.y + hh)
		@ctx.fill()
		# @ctx.stroke()
		@ctx.closePath()
		


	initColors: ->
		@colors = []
		@colors.push('rgba(220, 80, 110, 0.4)')
		@colors.push('rgba(75, 200, 230, 0.4)')
		@colors.push('rgba(145, 95, 180, 0.4)')
		@colors.push('rgba(80, 190, 90, 0.4)')
		@colors.push('rgba(190, 155, 80, 0.4)')