class LineView

	container				: null

	branches				: null
	splines					: null
	splineCurves			: null
	splineTs				: null
	stations				: null
	trains					: null
	tubes					: null
	timelines				: null

	model					: null
	color					: null
	index 					: null

	enabled					: true


	constructor: (@container, @model, @index) ->
		@initStations()
		@initTube()
		@initSplineTs()


	initStations: ->
		# center map on King's Cross
		s = app.stations.get('KXX')
		xy = AppUtils.mercatorEncode(s.get('lon'), s.get('lat'))
		cx = xy[0]
		cy = xy[1]

		@color = parseInt(@model.get('color')) || 0xffffff
		@branches = @model.get('branches')
		@stations = []
		@splineCurves = []
		@splines = []

		if !@branches then return

		# define sphere
		sphereGeometry = new THREE.SphereGeometry(1.5, 5, 5)
		# sphereMaterial = new THREE.MeshPhongMaterial({ color: @color, emissive: @color })
		sphereMaterial = new THREE.MeshBasicMaterial({ color: @color })

		spriteTexture = THREE.ImageUtils.loadTexture('img/flat.png')
		spriteMaterial = new THREE.SpriteMaterial( { map: spriteTexture, useScreenCoordinates: false, color: @color } )

		stationCodes = []

		for branch in @branches
			# a spline array for each branch
			spline = []
			@splines.push(spline)

			for stationCode in branch
				# get station data
				s = app.stations.get(stationCode)
				if !s then continue

				# code and depth
				code = @model.get('code')
				depth = s.get('depth')
				offset = 3

				# get xyz
				xy = AppUtils.mercatorEncode(s.get('lon'), s.get('lat'))
				x = xy[0] - cx
				y = xy[1] - cy
				z = depth[code] # get(depth).C

				# Circle Line exception
				# copy depth from D, H or M
				if (code == 'X')
					if (!z) then z = depth['D'] 
					if (!z) then z = depth['H'] 
					if (!z) then z = depth['M'] 

				# adjust depth if stations are too close together
				for key of depth
					if (key == code) then continue
					diff = z - depth[key]
					if (Math.abs(diff) < offset)
						if (diff > 0) then z += offset - diff
						else z -= offset + diff
				depth[code] = z

				# store Vector3D position in model
				position = new THREE.Vector3(x, -y, z - 100)
				s.set('position', position)

				# add branch spline
				spline.push(position)

				# skip if station is already stored
				skip = false
				for st in stationCodes
					if stationCode == st
						skip = true
						break
				if skip then continue

				# add station code to stored stations
				stationCodes.push(stationCode)
			
				# draw station

				##
				# sprites
				sprite = new THREE.Sprite(spriteMaterial)
				sprite.position = position
				sprite.scale.set( 4, 4, 1.0 )
				sprite.code = s.get('code')
				sprite.name = s.get('name')
				# color string eg. '255, 0, 0'
				sprite.color = ((sphereMaterial.color.r * 255) | 0) + ', ' + ((sphereMaterial.color.g * 255) | 0) + ', ' + ((sphereMaterial.color.b * 255) | 0)
				if (@model.get('code') == 'N') then sprite.color = '80, 80, 80'
				sprite.lineIndex = @index
				@stations.push(sprite)
				@container.add(sprite)
				##

				###
				# spheres
				sphere = new THREE.Mesh(sphereGeometry, sphereMaterial)
				sphere.position = position
				sphere.code = s.get('code')
				sphere.name = s.get('name')
				# color string eg. '255, 0, 0'
				sphere.color = ((sphereMaterial.color.r * 255) | 0) + ', ' + ((sphereMaterial.color.g * 255) | 0) + ', ' + ((sphereMaterial.color.b * 255) | 0)
				if (@model.get('code') == 'N') then sphere.color = '80, 80, 80'
				sphere.lineIndex = @index
				@stations.push(sphere)
				@container.add(sphere)
				###


	initTube: ->
		@tubes = []

		for spline in @splines
			splineCurve = new THREE.SplineCurve3(spline)
			@splineCurves.push(splineCurve)

			# THREE.TubeGeometry (path, segments, radius, radiusSegments, closed, debug)
			tubeGeometry = new THREE.TubeGeometry(splineCurve, spline.length * 8, 1.5, 4)
			tubeMaterial = new THREE.LineBasicMaterial({ color: @color, opacity: 0.5, transparent: true, linewidth: 1 })
			if (@model.get('code') == 'N') then tubeMaterial = new THREE.LineBasicMaterial({ color: @color, transparent: true, linewidth: 1 })
			
			# tube mesh
			# tube = new THREE.Mesh(tubeGeometry, tubeMaterial)

			# tube lines
			@reorderVertices(tubeGeometry)
			tube = new THREE.Line(tubeGeometry, tubeMaterial, THREE.LineStrip)
			@container.add(tube)
			@tubes.push(tube)


	initSplineTs: ->
		# store station:t pairs
		# e.g. @splineTs = [{ OXC:0.7, STP:0.8}, { BKR:0.5 }]
		@splineTs = []

		if !@branches then return

		for i in [0...@branches.length]
			branch = @branches[i]
			spline = @splineCurves[i]
			mapT = {}
			@splineTs[i] = mapT
			
			for station in branch
				mapT[station] = @getSplineT(spline, app.stations.get(station).get('position'))


	initTrains: ->
		@trains = []
		@timelines = []

		trainCollection = @model.get('trains')
		trainCollection.each (model, index, list) =>
			# if (index != 21) then return
			train = new TrainView(@container, model, @color)
			@trains.push(train)

		# model = trainCollection.at(23)
		# train = new TrainView(@container, model, @color)
		# @trains.push(train)

			timeline = new TimelineLite()
			timeline.timeScale(app.view.ui.guiData.speed)
			@timelines.push(timeline)
			train.t = -1

			scheduleCollection = model.get('schedule')
			scheduleCollection.each (model, index, list) =>

				curr = model
				next = if (index < list.length - 1) then list[index + 1] else model

				currStation = curr.get('station')
				nextStation = next.get('station')

				# find a branch that contains current and next stations
				branchIndex = @getBranchIndex(currStation, nextStation)

				if (branchIndex != -1)
					spline = @splineCurves[branchIndex]

					# current and next T on the spline 
					currT = @splineTs[branchIndex][currStation]
					nextT = @splineTs[branchIndex][nextStation]

					# if train is not AT a station, set currT in between last and next station
					if (index == 0)
						location = train.model.get('location')
						value = AppUtils.getTrainLocationValue(location)
						if (value) then currT += (nextT - currT) * value

					# console.log currStation, currT, nextT, currStation, nextStation, branchIndex

					timeline.to(train, 0.01, { t:currT, onUpdate: @onTrainUpdate, onUpdateParams: [train, spline] })
					timeline.to(train, next.get('time') - timeline._totalDuration, { t:nextT, ease:Linear.easeNone, onUpdate: @onTrainUpdate, onUpdateParams: [train, spline] })

			# hide train if it isn't placed on the spline
			# e.g. H.xml has trains going through Towerl Hill, which is not part of Hammersmith & City
			if (!timeline._totalDuration) 
				train.hide()
				@trains.pop()

		# if line is disabled, hide trains
		for train in @trains
			if (!@enabled) then train.hide()

	

	onTrainUpdate: (train, spline) ->
		# place the train on the spline
		train.train.position = spline.getPoint(train.t)

		# rotate the train to face the tangent of the current point on the spline
		tangent = spline.getTangent(train.t).normalize()
		up = new THREE.Vector3(0, 1, 0)
		axis = new THREE.Vector3().crossVectors(up, tangent).normalize()
		angle = Math.acos(up.dot(tangent))
		matrix = new THREE.Matrix4()
		matrix.makeRotationAxis(axis, angle)
		train.train.rotation.setEulerFromRotationMatrix(matrix)


	getStationIndexInBranch: (station, branchIndex) ->
		branch = @branches[branchIndex]
		for i in [0...branch.length]
			s = branch[i]
			if (station == s) then return i 
		return -1


	# Find an approximate T for a given point.
	getSplineT: (s, p, a = 0, b = 1) ->
		pa = s.getPoint(a)
		pb = s.getPoint(b)

		da = p.distanceToSquared(pa)
		db = p.distanceToSquared(pb)

		c = 0

		while (Math.min(da, db) > 1)
			mult = if (c > 5) then .5 else .25
			if da > db then a += (b - a) * mult
			else b -= (b - a) * mult

			pa = s.getPoint(a)
			pb = s.getPoint(b)

			da = p.distanceToSquared(pa)
			db = p.distanceToSquared(pb)

			if (c > 15) then break
			c++

		if (da < db) then return a
		else return b


	# Find a branch that contains both given stations
	getBranchIndex: (curr, next) ->
		branchCurr = -1
		branchNext = -1

		for i in [0...@branches.length]
			branch = @branches[i]
			for station in branch
				if (station == curr) then branchCurr = i
				if (station == next) then branchNext = i

				if (branchCurr > -1 && branchCurr == branchNext) then return branchCurr

		return -1


	# Find the first branch that contains the given station
	getFirstBranchIndex: (station) ->
		for i in [0...@branches.length]
			branch = @branches[i]
			for s in branch
				if (s == station) then return i

		return -1


	getSprite: (station) ->
		for sprite in @stations
			if (sprite.code == station) then return sprite

		return null


	# When lines are drawn between vertices of the normal tube geometry, the result is a spiral.
	# This method reorder the vertices so that lines are parallel.
	# It also reverts every other group of vertices so that lines are drawn in alternating directions.
	# e.g. assuming radiusSegments = 3
	# original	= [ 0,1,2,	3,4,5,	6,7,8 ]
	# result	= [ 0,3,6,	7,4,1,	2,5,8 ]
	reorderVertices: (tubeGeometry) ->
		vertices = tubeGeometry.vertices
		segments = tubeGeometry.radiusSegments
		length = vertices.length
		newVertices = []

		for s in [0...segments]
			temp = []
			if (s % 2)
				for i in [length + s - segments...0] by -segments
					temp.push(vertices[i])
			else
				for i in [s...length] by segments
					temp.push(vertices[i])

			newVertices = newVertices.concat(temp)

		tubeGeometry.vertices = newVertices



	enable: ->
		@enabled = true
		color = new THREE.Color(@color)

		for tube in @tubes
			tube.material.color = color
			if (@color == 256) then tube.material.opacity = 1

		for station in @stations
			station.material.color = color
			station.material.opacity = 1

		if !@trains then return null
		for train in @trains
			train.show()

		return null


	disable: ->
		@enabled = false
		color = new THREE.Color(0x444444)

		for tube in @tubes
			tube.material.color = color
			tube.material.opacity = 0.5

		for station in @stations
			station.material.color = color
			station.material.opacity = 0.3

		if !@trains then return null
		for train in @trains
			train.hide()

		return null