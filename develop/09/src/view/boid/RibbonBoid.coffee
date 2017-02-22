class RibbonBoid extends Boid

	particles				: null

	NUM_PARTICLES			: 10
	DISTANCE				: 20
	DISTANCE_SQ				: null
	DAMP					: 0.9


	constructor: (ctx, pos, color) ->
		super(ctx, pos, color)

		@DISTANCE_SQ = @DISTANCE * @DISTANCE
		@particles = []

		@initParticles()

		# @maxSpeed = 8
		# @maxSteer = 0.1 * @maxSpeed


	update: ->
		super()

		p = @particles[0]
		p.x = @pos.x
		p.y = @pos.y

		# elastic
		start = @NUM_PARTICLES - 1
		end = 0

		for i in [start..end]
			p = @particles[i]
			np = @particles[i + 1]
			pp = @particles[i - 1]

			if (i == 0) then pp = p
			else if (i == @NUM_PARTICLES - 1) then np = p

			# vertebral column
			p.vx *= @DAMP
			p.vy *= @DAMP

			p.x += p.vx
			p.y += p.vy

			ox = p.x
			oy = p.y

			dx = p.x - pp.x
			dy = p.y - pp.y
			dd = dx * dx + dy * dy

			if (dd > @DISTANCE_SQ)
				a = atan2(dy, dx)

				p.x = pp.x + @DISTANCE * cos(a)
				p.y = pp.y + @DISTANCE * sin(a)

				# if @mode == 3
					# damp = .15
				# else
				damp = .1
				p.vx += (p.x - ox) * damp
				p.vy += (p.y - oy) * damp

		# console.log @index, @particles.length


	draw: ->
		@ctx.beginPath()
		# @ctx.rotate(@vel.headingXY())
		@ctx.arc(@pos.x, @pos.y, @radius * 0.5, 0, TWO_PI)

		# draw particles
		# for p in @particles
			# @ctx.arc(p.x, p.y, 2, 0, TWO_PI)

		@ctx.fillStyle = @color
		@ctx.fill()

		##
		# draw vertebral column
		@ctx.beginPath()
		for i in [0...@NUM_PARTICLES]
			p = @particles[i]
			np = @particles[i + 1]
			pp = @particles[i - 1]

			if (i == 0) then pp = p
			else if (i == @NUM_PARTICLES - 1) then np = p

			mx = p.x + (np.x - p.x) * .5
			my = p.y + (np.y - p.y) * .5

			@ctx.quadraticCurveTo(p.x, p.y, mx, my)
		@ctx.strokeStyle = @color
		@ctx.lineWidth = 1
		@ctx.stroke()
		##


	initParticles: ->
		for i in [0...@NUM_PARTICLES]
			p =
				x			: @pos.x
				y			: @pos.y
				vx			: 0
				vy			: 0
				angle 		: 0
				thickness 	: 0
				# anchors m and n
				mx			: 0
				my			: 0
				nx			: 0
				ny			: 0

			# if (i < @NUM_PARTICLES * .5) then p.thickness = @THICKNESS * (i / @NUM_PARTICLES)
			# else p.thickness = @THICKNESS * ((@NUM_PARTICLES - i) / @NUM_PARTICLES)
			# p.thickness = @THICKNESS * (Math.abs(i - @NUM_PARTICLES * .5) / @NUM_PARTICLES)
			# p.thickness = @THICKNESS * ((i - @NUM_PARTICLES) / @NUM_PARTICLES)
				
			@particles.push(p)


	wrap: () ->
		p = @particles[@particles.length - 1]
		px = 0
		py = 0
		margin = @DISTANCE * 2
		wrapped = false

		# horizontal
		if (@pos.x > @ctx.width && p.x > @ctx.width) 
			@pos.x = 0
			px = -margin
			wrapped = true
		else if (@pos.x < 0 && p.x < 0) 
			@pos.x = @ctx.width
			px = margin
			wrapped = true

		# vertical
		if (@pos.y > @ctx.height && p.y > @ctx.height) 
			@pos.y = 0
			py = -margin
			wrapped = true
		else if (@pos.y < 0 && p.y < 0) 
			@pos.y = @ctx.height
			py = margin
			wrapped = true

		# if wrapped, reposition all particles to head's position
		if wrapped
			for p in @particles
				p.x = @pos.x + px
				p.y = @pos.y + py