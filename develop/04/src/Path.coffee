class Path

	ctx 				: null
	points				: null
	radius				: 20
	direction			: null
	segment 			: null

	constructor: (ctx) ->

		@ctx = ctx
		@points = []
		@direction = new Vec3D()


	addPoint: (vec3D) ->
		@points.push(vec3D)


	removePoint: (index) ->
		@points.splice(index, 1)


	getNormalPoint: (p, last = null, lastSegment = -1) ->
		distanceToPath = 1000000
		distanceToLast = 1000000
		target = null

		if !@points.length then return target


		#if no last segment is set, search for the closest point in the entire path
		# else, search for the closest point in the next segment
		start = 0
		end = @points.length - 1
		if (lastSegment > -1 && lastSegment < @points.length - 1)
			start = lastSegment
			end = min(lastSegment + 2, @points.length - 1)

		for i in [start...end]
			# path start and end points
			pointA = @points[i]
			pointB = @points[i + 1]
			# vector between given vector and path start point
			vecA = p.sub(pointA)
			# vector between path start and end points
			vecB = pointB.sub(pointA)
			# normalize to the dot product between A and B
			vecB.normalize()
			vecB.scaleSelf(vecA.dot(vecB))
			# find the normal point on the path
			pointN = pointA.add(vecB)

			# if normal point is below pointA, use pointA
			# if normal point is beyond pointB, use pointB
			da = pointN.distanceTo(pointA)
			db = pointN.distanceTo(pointB)
			pathLine = pointB.sub(pointA)
			lineLength = pathLine.magnitude()
			if (da > lineLength) then pointN = pointB.copy()
			else if (db > lineLength) then pointN = pointA.copy()

			# if beyond pointB and not the last segment, skip to next
			if (da > lineLength && i < end - 1) then continue

			# find closest normal point from all paths
			# and the closest to the last normal point
			distPath = p.distanceTo(pointN)
			if (last) then distLast = last.distanceTo(pointN)
			else distLast = 0
			if (distPath < distanceToPath && distLast <= distanceToLast)
				distanceToPath = distPath
				distanceToLast = distLast
				target = pointN
				# store private direction
				@direction = pathLine
				# store current path segment
				# if last segment and beyond pointB, reset segment to -1
				@segment = if (i >= @points.length - 2 && da > lineLength) then -1 else i

			# store last target
			# if (!target) then @pointN = target

		target


	render: ->
		@ctx.strokeStyle = 'rgba(100, 100, 100, 0.3)'
		@ctx.lineWidth = 1

		if !@points.length then return

		# Draw Polygon around path
		for i in [0...@points.length - 1]
			start = @points[i]
			end = @points[i + 1]
			line = end.sub(start)
			normal = new Vec3D(line.y, -line.x, 0)
			normal.normalizeTo(@radius)

			# Polygon has four vertices
			a = start.add(normal)
			b = end.add(normal)
			c = end.sub(normal)
			d = start.sub(normal)

			@ctx.beginPath()
			@ctx.moveTo(a.x, a.y)
			@ctx.lineTo(b.x, b.y)
			@ctx.lineTo(c.x, c.y)
			@ctx.lineTo(d.x, d.y)
			@ctx.lineTo(a.x, a.y)
			@ctx.stroke()
			@ctx.closePath()