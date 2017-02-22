class SceneRopeBall extends AbstractScene

	ctx 					: null
	index					: null
	reindeer 				: null

	boids 					: null
	numBoids				: 0


	constructor: (@ctx, @index) ->
		super

		@numBoids = @reindeer.anchors.length
		@initBoids()

		# @ctx.globalCompositeOperation = 'lighter'


	update: ->
		super

		hw = @ctx.width * .5
		hh = @ctx.height * .5

		i = 0
		for boid in @boids
			a = @reindeer.anchors[i]
			if (@ctx.down) then boid.acc.addSelf(boid.seek(new Vec3D(@ctx.mouse.x, @ctx.mouse.y, 0)).scaleSelf(0.3))
			boid.acc.addSelf(boid.arrive(new Vec3D(a.pos.x + hw, a.pos.y + hh, 0)).scaleSelf(0.5))
			boid.acc.addSelf(boid.wander().scaleSelf(0.2))
			# boid.acc.addSelf(boid.separate(@boids))
			# boid.acc.addSelf(boid.cohesion(@boids).scaleSelf(0.01))
			boid.update()
			boid.bounce()
			i++


	draw: ->
		hw = @ctx.width * .5
		hh = @ctx.height * .5
		scale = 1

		@ctx.globalCompositeOperation = 'source-over'

		# @ctx.fillStyle = 'rgba(100, 200, 0, 0.3)'
		@ctx.strokeStyle = 'rgba(200, ' + floor(random(125, 200)) + ', 35, 0.7)'
		@ctx.lineWidth = 1
		@ctx.beginPath()

		for i in [0...@reindeer.anchors.length]
			a = @reindeer.anchors[i]
			b = @boids[i]
			c = a.other
			@ctx.moveTo(a.pos.x * scale + hw, a.pos.y * scale + hh)
			@ctx.lineTo(b.pos.x, b.pos.y)
			# if (!c) then continue
			# @ctx.lineTo(c.pos.x * scale + hw, c.pos.y * scale + hh)

		@ctx.stroke()
		# @ctx.fill()
		@ctx.closePath()

		##
		for a in @reindeer.anchors
			@ctx.beginPath()
			# @ctx.fillStyle = '#222'
			@ctx.strokeStyle = a.color
			@ctx.arc(a.pos.x * scale + hw, a.pos.y * scale + hh, 1, 0, TWO_PI)
			# @ctx.fill()
			@ctx.stroke()
			@ctx.closePath()
		##

		for boid in @boids
			boid.draw()



	initBoids: ->
		hw = @ctx.width * .5
		hh = @ctx.height * .5

		@boids = []
		for i in [0...@numBoids]
			a = @reindeer.anchors[i]
			pos = new Vec3D(a.pos.x + hw, a.pos.y + hh, 0)
			color = 'rgb(' + floor(random(160, 220)) + ', ' + floor(random(120, 140)) + ', 0)'
			if (random() > 0.9) then color = '#ffff00'
			# color = '#bbb'
			b = new Boid(@ctx, pos, color)
			b.radius = random(2, 6)
			b.index = i
			b.maxSpeed = random(1, 3)
			if (random() > 0.9) then b.maxSpeed = 6
			@boids.push(b)	