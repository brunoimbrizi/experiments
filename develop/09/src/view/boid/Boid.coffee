class Boid

	ctx 					: null
	pos 					: null
	vel 					: null
	acc						: null
	radius 					: null
	color 					: null
	type 					: null
	img 					: null

	wrapped 				: null

	maxSpeed    			: null
	maxSteer   				: null
	wanderTheta				: null
	arriveRadius			: 50.0

	SEPARATION_RADIUS		: 30.0
	ALIGNMENT_RADIUS		: 40.0
	COHESION_RADIUS			: 60.0
	SEPARATION_RADIUS_SQ	: null
	ALIGNMENT_RADIUS_SQ		: null
	COHESION_RADIUS_SQ		: null


	constructor: (@ctx, @pos, @type) ->

		@color = '#000'

		# @vel = new Vec3D(random(-1,1), random(-1,1), 0)
		@vel = new Vec3D()
		@acc = new Vec3D()
		@radius = 4.0

		# @img = document.getElementById('boid')

		# @maxSpeed = random(1.0, 2.0)
		@maxSpeed = 5.0
		@maxSteer = 0.1 * @maxSpeed

		@pathLastSegment = -1
		@wanderTheta = 0.0

		@SEPARATION_RADIUS_SQ = @SEPARATION_RADIUS * @SEPARATION_RADIUS
		@ALIGNMENT_RADIUS_SQ = @ALIGNMENT_RADIUS * @ALIGNMENT_RADIUS
		@COHESION_RADIUS_SQ = @COHESION_RADIUS * @COHESION_RADIUS


	update: ->
		@acc.limit(@maxSteer)
		@vel.addSelf(@acc)
		@vel.limit(@maxSpeed)
		@pos.addSelf(@vel)
		@acc.clear()


	draw: ->
		# @ctx.translate(@pos.x, @pos.y)
		# @ctx.rotate(@vel.headingXY())
		
		@ctx.beginPath()
		# @ctx.moveTo(@radius * 0.6, 0)
		# @ctx.lineTo(@radius * -0.3, @radius * -0.4)
		# @ctx.lineTo(@radius * -0.3, @radius * 0.4)
		# @ctx.lineTo(@radius * 0.6, 0)
		# @ctx.arc(0, 0, @radius * 0.8, 0, TWO_PI)
		@ctx.arc(@pos.x, @pos.y, @radius * 0.8, 0, TWO_PI)
		@ctx.fillStyle = @color
		@ctx.fill()
		@ctx.closePath()

		# @ctx.drawImage(@img, 0, 0)
		# @ctx.setTransform(1, 0, 0, 1, 0, 0)

	wrap: ->
		ox = @pos.x
		oy = @pos.y
		@wrapped = false

		# horizontal
		if (@pos.x > @ctx.width) then @pos.x = 0
		else if (@pos.x < 0) then @pos.x = @ctx.width

		# vertical
		if (@pos.y > @ctx.height) then @pos.y = 0
		else if (@pos.y < 0) then @pos.x = @ctx.height

		if (ox != @pos.x || oy != @pos.y) then @wrapped = true


	bounce: ->
		# horizontal
		if (@pos.x > @ctx.width || @pos.x < 0) then @vel.x *= -1

		# vertical
		if (@pos.y > @ctx.height || @pos.y < 0) then @vel.y *= -1


	respawn: ->
		ox = @pos.x
		oy = @pos.y
		@wrapped = false

		# horizontal
		if (@pos.x > @ctx.width) then @pos.x = 0
		else if (@pos.x < 0) then @pos.x = 0

		# vertical
		if (@pos.y > @ctx.height) then @pos.x = 0
		else if (@pos.y < 0) then @pos.x = 0

		if (ox != @pos.x || oy != @pos.y) then @wrapped = true



	# __________________________________________________________________
	#
	#	STEERING
	# __________________________________________________________________

	seek: (target) ->
		steering = new Vec3D()
		steering = target.sub(@pos)
		steering.limit(@maxSteer)
		return steering


	flee: (target) ->
		Vec3D steering
		steering = @pos.sub(target)
		steering.limit(@maxSteer)
		return steering


	arrive: (target) ->
		direction = target.sub(@pos)
		distance = direction.magnitude()
		if (distance > @arriveRadius) then targetSpeed = @maxSpeed
		else targetSpeed = @maxSpeed * distance / @arriveRadius
		targetVelocity = direction
		targetVelocity.normalizeTo(targetSpeed)
		steering = targetVelocity.sub(@vel)
		# steering.scaleSelf(0.5)
		steering.limit(@maxSteer)
		return steering;


	pursue: (boid) ->
		direction = boid.pos.sub(@pos)
		distance = direction.magnitude()
		speed = @vel.magnitude()

		if (speed <= distance) then prediction = 1.0
		else prediction = distance / speed
		
		predicted = boid.vel.scale(prediction)
		target = boid.pos.add(predicted)
		return @arrive(target)


	evade: (boid) ->
		direction = boid.pos.sub(@pos)
		distance = direction.magnitude()
		speed = @vel.magnitude()
		if (speed <= distance) then prediction = 1.0
		else prediction = distance / speed;
		predicted = boid.vel.scale(prediction)
		target = boid.pos.add(predicted)
		return @flee(target)


	wander: ->
		wanderOffset = 60.0
		wanderRadius = 16.0
		wanderRate = 0.25
		@wanderTheta += random(-wanderRate, wanderRate)
		target = @vel.copy().normalizeTo(wanderOffset)
		target.addSelf(new Vec3D(cos(@wanderTheta) * wanderRadius, sin(@wanderTheta) * wanderRadius, 0))
		target.addSelf(@pos);
		###
		# debug draw
		@ctx.beginPath();
		@ctx.arc(target.x, target.y, 2, 0, TWO_PI)
		@ctx.fillStyle = 'blue';
		@ctx.fill()
		###
		return @seek(target)


	separate: (boids) ->
		steering = new Vec3D()
		count = 0
		for b in boids
			if (@ == b) then continue
			d = @pos.distanceTo(b.pos)
			if (d > 0 && d <= @SEPARATION_RADIUS)
				repulse = @pos.sub(b.pos)
				repulse.normalizeTo(1.0 / d)
				steering.addSelf(repulse)
				count++

		if (count > 0) then steering.scaleSelf(1.0 / count)
		###
		if (steering.magSquared() > 0)
			steering.normalizeTo(maxSpeed);
			steering.subSelf(vel);
			steering.limit(maxSteer);
		###
		# steering.limit(@maxSteer)
		return steering


	align: (boids) ->
		steering = new Vec3D()
		count = 0;
		for b in boids
			if (@ == b) then continue
			d = @pos.distanceToSquared(b.pos)
			if (d > 0 && d <= @ALIGNMENT_RADIUS_SQ)
				steering.addSelf(b.vel)
				count++
		
		if (count > 0) then steering.scaleSelf(1.0 / count)
		# steering.limit(@maxSteer)
		return steering


	cohesion: (boids) ->
		attraction = new Vec3D()
		count = 0
		for b in boids
			if (@ == b) then continue
			d = @pos.distanceToSquared(b.pos)
			if (d > 0 && d <= @COHESION_RADIUS_SQ)
				attraction.addSelf(b.pos)
				count++

		if (count > 0)
			attraction.scaleSelf(1.0 / count)
		
		steering = attraction.sub(@pos)
		# steering.limit(@maxSteer)
		return steering