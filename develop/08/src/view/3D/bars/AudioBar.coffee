class AudioBar

	mesh 					: null
	geometry				: null
	material				: null

	index					: null
	segments				: null
	radius					: null
	thickness				: null
	depth					: null

	oldValue				: null
	circ 					: 1

	shape					: null

	scaleX					: false
	scaleY					: false
	scaleZ					: true

	rotateX					: true
	rotateY					: true
	rotateZ					: true

	constRotationZ			: 0

	targetRotationX			: null
	targetRotationY			: null
	targetRotationZ			: null

	@SHAPE_BAR				: 'bar'
	@SHAPE_CIRCLE			: 'circle'


	constructor: (@index, @radius = 30, @thickness = 3, @depth = 2, @segments = 60) ->
		@shape = AudioBar.SHAPE_CIRCLE

		@initMesh()


	initMesh: ->
		# square
		points = []
		points.push(new THREE.Vector3(@radius - @thickness, 0, @depth))
		points.push(new THREE.Vector3(@radius - @thickness, 0, -@depth))
		points.push(new THREE.Vector3(@radius, 0, -@depth))
		points.push(new THREE.Vector3(@radius, 0, @depth))
		points.push(new THREE.Vector3(@radius - @thickness, 0, @depth))

		# mesh
		@geometry = new THREE.LatheGeometry(points, @segments, 0, TWO_PI - 0.001)
		# @material = new THREE.MeshPhongMaterial({ color:0xffffff, emissive:0x222222, ambient:0xffffff, shininess:100 })
		@material = new THREE.MeshLambertMaterial({ color:0xffffff, emissive:0x222222, ambient:0xffffff, shininess:100 })
		@material.shading = THREE.FlatShading
		# @material.shading = THREE.SmoothShading
		# @material.blending = THREE.SubtractiveBlending
		# @material.wireframe = true
		@mesh = new THREE.Mesh(@geometry, @material)

		# hide internal faces
		faces = @geometry.faces
		length = faces.length
		for i in [0...length] by 8
			faces[i].a = faces[i].b = faces[i].c = 0
			faces[i + 1].a = faces[i + 1].b = faces[i + 1].c = 0

		# hide external faces
		# for i in [4...length] by 8
			# faces[i].a = faces[i].b = faces[i].c = 0
			# faces[i + 1].a = faces[i + 1].b = faces[i + 1].c = 0


	update: (value = 0) ->
		@geometry.verticesNeedUpdate = true

		# diff = max(value - @oldValue, 0)
		diff = value - @oldValue

		@targetRotationZ += value * @constRotationZ

		if (@targetRotationX) then @targetRotationX += diff
		if (@targetRotationY) then @targetRotationY += diff * 2
		if (@targetRotationZ) then @targetRotationZ += diff * 2

		if (@targetRotationX > TWO_PI) 
			@mesh.rotation.x -= TWO_PI
			@targetRotationX -= TWO_PI
		if (@targetRotationY > TWO_PI) 
			@mesh.rotation.y -= TWO_PI
			@targetRotationY -= TWO_PI
		if (@targetRotationZ > TWO_PI) 
			@mesh.rotation.z -= TWO_PI
			@targetRotationZ -= TWO_PI

		if (@rotateX) then @mesh.rotation.x += (@targetRotationX - @mesh.rotation.x) * 0.1
		if (@rotateY) then @mesh.rotation.y += (@targetRotationY - @mesh.rotation.y) * 0.05
		if (@rotateZ) then @mesh.rotation.z += (@targetRotationZ - @mesh.rotation.z) * 0.1

		if (value - @oldValue > 0.1) then @radius += value
		@oldValue = value

		if (@scaleX) then @mesh.scale.x = value
		if (@scaleY) then @mesh.scale.y = value
		if (@scaleZ) then @mesh.scale.z = value

		# aseg = (TWO_PI - 0.001) / @segments
		aseg = ((PI * @circ) + PI - 0.001) / @segments
		hvalue = value * @segments
		vertices = @geometry.vertices
		length = vertices.length

		# update vertices based on value
		for i in [0...length] by 4
			v0 = vertices[i]
			v1 = vertices[i + 1]
			v2 = vertices[i + 2]
			v3 = vertices[i + 3]

			v0.z = v3.z = @depth
			v1.z = v2.z = -@depth

			seg = floor(i / 4)
			a = min(seg, hvalue) * aseg

			# consider the circunference factor to switch between circle and bar
			v0.x = v1.x = cos(a) * (@radius - @thickness * @circ)
			v0.y = v1.y = sin(a) * (@radius - @thickness) * @circ + (1 - @circ) * -@thickness

			v2.x = v3.x = cos(a) * (@radius) 
			v2.y = v3.y = sin(a) * (@radius) * @circ


		return null