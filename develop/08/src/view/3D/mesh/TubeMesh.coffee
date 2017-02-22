class TubeMesh

	mesh 					: null
	geometry				: null
	material				: null

	w						: null
	h						: null
	segmentsW				: null
	segmentsH				: null 
	hseg 					: null				

	constructor: ->
		@segmentsW = 4
		@segmentsH = 8
		@hseg = @h / @segmentsH

		spline = []
		# spline.push(new THREE.Vector3(0, 50, 0))
		# spline.push(new THREE.Vector3(0, -50, 0))

		@radius = 50
		aseg = TWO_PI / @segmentsH

		for i in [0..@segmentsH]
			a = aseg * i
			spline.push(new THREE.Vector3(sin(a) * @radius, cos(a) * @radius, 0))

		splineCurve = new THREE.SplineCurve3(spline)

		@geometry = new THREE.TubeGeometry(splineCurve, @segmentsH, 5, @segmentsW)
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
			seg = floor(i / @segmentsW)
			y = min(seg, hvalue) * @hseg
			v.y = (@h * 0.5) - y
		###

		aseg = TWO_PI / @segmentsH
		hvalue = value * @segmentsH
		vertices = @geometry.vertices
		length = vertices.length

		for i in [0...length]
			v = vertices[i]
			seg = floor(i / @segmentsW)
			a = min(seg, hvalue) * aseg
			v.x = sin(a) * @radius
			v.y = cos(a) * @radius

		return null