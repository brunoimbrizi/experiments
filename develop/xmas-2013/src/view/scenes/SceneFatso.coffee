class SceneFatso extends AbstractScene


	constructor: (@ctx, @index) ->
		super
		@name = 'Fatso'


	start: ->
		if (!@audio.sourceNode) then return
		@audio.sourceNode.playbackRate.value = 0.8
		@speed = 23.3


	draw: ->
		hw = @ctx.width * .5
		hh = @ctx.height * .5
		scale = 1
		radiusX = 150
		radiusY = 100

		@ctx.globalCompositeOperation = 'source-over'
		
		@ctx.lineCap = 'round'
		@ctx.lineJoin = 'round'
		@ctx.strokeStyle = '#fff'
		# @ctx.fillStyle = '#E37C49'

		for i in [0...@reindeer.anchors.length - 1]
			a = @reindeer.anchors[i]
			b = @reindeer.anchors[i + 1]

			@ctx.beginPath()
			@ctx.moveTo(a.pos.x + cos(a.angle) * radiusX + hw, a.pos.y + sin(a.angle) * radiusY + hh)
			@ctx.lineTo(b.pos.x + cos(b.angle) * radiusX + hw, b.pos.y + sin(b.angle) * radiusY + hh)
			@ctx.lineWidth = a.lineWidth
			@ctx.stroke()
			@ctx.closePath()

		a = @reindeer.anchors[@reindeer.anchors.length - 1]
		b = @reindeer.anchors[0]
		@ctx.moveTo(a.pos.x + cos(a.angle) * radiusX + hw, a.pos.y + sin(a.angle) * radiusY + hh)
		@ctx.lineTo(b.pos.x + cos(b.angle) * radiusX + hw, b.pos.y + sin(b.angle) * radiusY + hh)
		@ctx.stroke()


	initReindeer: ->
		super

		# set extra properties
		for i in [0...@reindeer.anchors.length]
			a = @reindeer.anchors[i]
			a.lineWidth = i % 24
			if (a.lineWidth > 12) then a.lineWidth = 24 - a.lineWidth
			# a.lineWidth /= 3

			a.angle = Math.atan2(a.positions[0].y, a.positions[0].x)