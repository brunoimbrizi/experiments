class ShapeMesh

	mesh 					: null
	geometry				: null
	material				: null

	w						: null
	h						: null
	segmentsW				: null
	segmentsH				: null 
	hseg 					: null				

	constructor: ->
		@w = 10
		@h = 100
		@segmentsW = 1
		@segmentsH = 5
		@hseg = @h / @segmentsH

		points = []
		# for i in [0...@segmentsH]
			# x = i % (@segmentsW + 1) * @w - (@w * 0.5)
			# y = (@h * 0.5) - floor(i / (@segmentsW + 1)) * @hseg

		###
		points.push(new THREE.Vector2(-5, 50))
		points.push(new THREE.Vector2(5, 50))
		points.push(new THREE.Vector2(5, -50))
		points.push(new THREE.Vector2(-5, -50))
		shape = new THREE.Shape(points)
		###

		segments = 25
		radius = 50
		thickness = 2
		aseg = TWO_PI / (segments + 1)

		for i in [0..segments]
			a = aseg * i
			points.push(new THREE.Vector3(sin(a) * (radius + thickness), cos(a) * (radius + thickness), 0))

		for i in [segments..0]
			a = aseg * i
			x = sin(a) * (radius - thickness)
			y = cos(a) * (radius - thickness)
			points.push(new THREE.Vector3(x, y, 0))

		# console.log(points)

		shape = new THREE.Shape(points)

		# @geometry = new THREE.ShapeGeometry( shape )
		@geometry = new THREE.ExtrudeGeometry( shape, { bevelEnabled:false, amount:5 } )

		# @geometry = new THREE.PlaneGeometry(@w, @h, @segmentsW, @segmentsH)
		@material = new THREE.MeshBasicMaterial( { color:0x444444, wireframe:true } )
		@mesh = new THREE.Mesh(@geometry, @material)


	update: (value = 1) ->
		@geometry.verticesNeedUpdate = true

		###
		hvalue = value * @segmentsH
		vertices = @geometry.vertices
		length = vertices.length

		for i in [0...length]
			v = vertices[i]
			seg = floor(i / (@segmentsW + 1))
			y = min(seg, hvalue) * @hseg
			v.y = (@h * 0.5) - y
		###

		segments = 20
		radius = 50
		thickness = 5
		aseg = TWO_PI / (segments + 1)

		hvalue = value * segments
		vertices = @geometry.vertices
		length = vertices.length

		for i in [0...length * .5]
			v = vertices[i]
			seg = floor(i / @segmentsW)
			a = min(seg, hvalue) * aseg
			v.x = sin(a) * radius
			v.y = cos(a) * radius

		return null