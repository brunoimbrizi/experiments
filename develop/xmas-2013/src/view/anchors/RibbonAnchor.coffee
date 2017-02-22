#<< view/anchors/Anchor
class RibbonAnchor extends Anchor

	particles				: null

	NUM_PARTICLES			: 10
	LENGTH					: 8
	DISTANCE_SQ				: 9
	DAMP					: 0.99


	constructor: (@index, @pos) ->
		super

		@length = @LENGTH
		@initParticles()


	update: ->
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
			if(i) then p.vy += 0.3

			p.x += p.vx
			p.y += p.vy

			ox = p.x
			oy = p.y

			dx = p.x - pp.x
			dy = p.y - pp.y
			dd = dx * dx + dy * dy

			if (dd > @DISTANCE_SQ)
				a = atan2(dy, dx)

				p.x = pp.x + @length * cos(a)
				p.y = pp.y + @length * sin(a)

				# if @mode == 3
					# damp = .15
				# else
				damp = .1
				p.vx += (p.x - ox) * damp
				p.vy += (p.y - oy) * damp

		# console.log @index, @particles.length


	draw: ->
		###
		@ctx.beginPath()
		# @ctx.rotate(@vel.headingXY())
		@ctx.arc(@pos.x, @pos.y, @radius * 0.5, 0, TWO_PI)

		# draw particles
		# for p in @particles
			# @ctx.arc(p.x, p.y, 2, 0, TWO_PI)

		@ctx.fillStyle = @color
		@ctx.fill()
		###

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
		@particles = []
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