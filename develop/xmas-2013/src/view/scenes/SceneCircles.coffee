class SceneCircles extends AbstractScene


	constructor: (@ctx, @index) ->
		super

		# tween circles
		# @tweenCircle(@reindeer.anchors[0])
		for a in @reindeer.anchors
			@tweenCircle(a)


	draw: ->
		hw = @ctx.width * .5
		hh = @ctx.height * .5
		scale = 1

		@ctx.globalCompositeOperation = 'source-over'

		# circles
		if (app.view.ui.drawAnchors)
			@ctx.lineCap = 'butt'
			# @ctx.strokeStyle = '#E6335A'
			@ctx.fillStyle = '#E6335A'
			@ctx.beginPath()
			for a in @reindeer.anchors
				@ctx.moveTo(a.pos.x * scale + hw, a.pos.y * scale + hh)
				@ctx.arc(a.pos.x * scale + hw, a.pos.y * scale + hh, a.radius, 0, TWO_PI)
				@ctx.arc(a.pos.x * scale + hw, a.pos.y * scale + hh, a.radius2, 0, TWO_PI, true)
				# @ctx.lineWidth = a.lineWidth
			# @ctx.stroke()
			@ctx.fill()
			@ctx.closePath()


	tweenCircle: (a) =>
		# if (a.lineWidth > 0.1)
		a.radius = 2
		a.radius2 = 0
		a.lineWidth = 5
		radius = random(10)
		# radius = ((a.pos.y + 300) / 540) * 15
		# radius = (300 - Math.abs(a.pos.y)) / 300 * 10
		radius2 = radius
		lineWidth = 0
		delay = random(0.8)
		# delay = (a.index + 1) * 0.1

		TweenMax.to(a, 0.6, { radius:radius, lineWidth:lineWidth, delay:delay, ease:Quart.easeOut })
		TweenMax.to(a, 0.6, { radius2:radius2, delay:delay, ease:Quart.easeInOut, onCompleteParams:[a], onComplete:@tweenCircle })