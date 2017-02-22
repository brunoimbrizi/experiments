class LatheMesh

	mesh 					: null
	geometry				: null
	material				: null

	segments				: null
	radius					: null
	thickness				: null
	depth					: null


	constructor: ->
		@segments = 24
		@radius = 50
		@thickness = 4
		@depth = 5

		points = []
		points.push(new THREE.Vector3(@radius - @thickness, 0, @depth))
		points.push(new THREE.Vector3(@radius - @thickness, 0, -@depth))
		points.push(new THREE.Vector3(@radius, 0, -@depth))
		points.push(new THREE.Vector3(@radius, 0, @depth))
		points.push(new THREE.Vector3(@radius - @thickness, 0, @depth))

		@geometry = new THREE.LatheGeometry(points, @segments, 0, TWO_PI - 0.01)
		@material = new THREE.MeshPhongMaterial({ color:0xff0000, emissive:0x222222, ambient:0xffffff, shininess:100 })
		@material.shading = THREE.FlatShading
		# @material.wireframe = true
		@mesh = new THREE.Mesh(@geometry, @material)

		# hide internal faces
		faces = @geometry.faces
		length = faces.length
		for i in [0...length] by 8
			faces[i].a = faces[i].b = faces[i].c = 0
			faces[i + 1].a = faces[i + 1].b = faces[i + 1].c = 0


	update: (value = 1) ->
		@geometry.verticesNeedUpdate = true

		aseg = (TWO_PI - 0.01) / @segments
		hvalue = value * @segments
		vertices = @geometry.vertices
		length = vertices.length

		for i in [0...length] by 4
			v0 = vertices[i]
			v1 = vertices[i + 1]
			v2 = vertices[i + 2]
			v3 = vertices[i + 3]

			seg = floor(i / 4)
			a = min(seg, hvalue) * aseg

			v0.x = v1.x = cos(a) * (@radius - @thickness)
			v0.y = v1.y = sin(a) * (@radius - @thickness)

			v2.x = v3.x = cos(a) * (@radius)
			v2.y = v3.y = sin(a) * (@radius)

		return null