class _AudioBar

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
		# @material = new THREE.MeshPhongMaterial({ color:0xff0000, emissive:0x222222, ambient:0xffffff, shininess:100 })
		@material = new THREE.MeshLambertMaterial({ color:0xff0000, emissive:0x222222, ambient:0xffffff, shininess:100 })
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

		@mesh.rotation.x += (@targetRotationX - @mesh.rotation.x) * 0.1
		@mesh.rotation.y += (@targetRotationY - @mesh.rotation.y) * 0.05
		@mesh.rotation.z += (@targetRotationZ - @mesh.rotation.z) * 0.1

		if (value - @oldValue > 0.1) then @radius += value
		@oldValue = value

		if (@scaleX) then @mesh.scale.x = value
		if (@scaleY) then @mesh.scale.y = value
		if (@scaleZ) then @mesh.scale.z = value

		# if (@morphing) then return

		# aseg = (TWO_PI - 0.001) / @segments
		aseg = ((PI * @circ) + PI - 0.001) / @segments
		hvalue = value * @segments
		vertices = @geometry.vertices
		length = vertices.length

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

			###
			# basic version, before circunference factor
			v0.x = v1.x = cos(a) * (@radius - @thickness)
			v0.y = v1.y = sin(a) * (@radius - @thickness)

			v2.x = v3.x = cos(a) * (@radius) 
			v2.y = v3.y = sin(a) * (@radius)
			###


			###
			# circle
			if (@shape == AudioBar.SHAPE_CIRCLE)
				seg = floor(i / 4)
				a = min(seg, hvalue) * aseg

				v0.x = v1.x = cos(a) * (@radius - @thickness)
				v0.y = v1.y = sin(a) * (@radius - @thickness)

				v2.x = v3.x = cos(a) * (@radius)
				v2.y = v3.y = sin(a) * (@radius)

			# bar
			else if (@shape == AudioBar.SHAPE_BAR)
				aseg = size / @segments
				seg = floor((length - 4 - i) / 4)
				# seg = floor(i / 4)
				a = min(seg, hvalue) * aseg - size * value * .5

				v0.y = v1.y = 0
				v0.x = v1.x = v2.x = v3.x = a
				v2.y = v3.y = @thickness
			###

		return null


	###
	morphToBar: ->
		if (@shape == AudioBar.SHAPE_BAR) then return
		@morphing = true
		@shape = AudioBar.SHAPE_BAR

		size = @radius * PI
		aseg = size / @segments
		hvalue = @oldValue * @segments
		vertices = @geometry.vertices
		length = vertices.length
		t = 0.4

		for i in [0...length] by 4
			v0 = vertices[i]
			v1 = vertices[i + 1]
			v2 = vertices[i + 2]
			v3 = vertices[i + 3]

			seg = floor((length - 4 - i) / 4)
			# seg = floor(i / 4)
			# a = seg * (size / hvalue) - size * .5
			a = min(seg, hvalue) * aseg - size * @oldValue * .5

			# d = if (i < length * 0.5) then i * 0.01 else (length - 4 - i) * 0.01
			# slice =  TWO_PI / length
			# d = @index * 0.1
			# d = (Math.acos(seg)) * 0.5
			# d = (Math.atan(seg * slice)) * 0.5
			# d *= 0.1
			d = 0

			TweenLite.to(v0, t, { x:a, y:0, delay:d, ease:Quart.easeIn })
			TweenLite.to(v1, t, { x:a, y:0, delay:d, ease:Quart.easeIn })
			TweenLite.to(v2, t, { x:a, y:@thickness, delay:d, ease:Quart.easeIn })
			TweenLite.to(v3, t, { x:a, y:@thickness, delay:d, ease:Quart.easeIn })

		TweenLite.delayedCall(t, => @morphing = false )

		return null


	morphToCircle: ->
		if (@shape == AudioBar.SHAPE_CIRCLE) then return
		@morphing = true
		@shape = AudioBar.SHAPE_CIRCLE

		aseg = (TWO_PI - 0.001) / @segments
		hvalue = @oldValue * @segments
		vertices = @geometry.vertices
		length = vertices.length
		t = 0.4

		for i in [0...length] by 4
			v0 = vertices[i]
			v1 = vertices[i + 1]
			v2 = vertices[i + 2]
			v3 = vertices[i + 3]

			seg = floor(i / 4)
			a = min(seg, hvalue) * aseg

			v01x = cos(a) * (@radius - @thickness)
			v01y = sin(a) * (@radius - @thickness)

			v23x = cos(a) * (@radius)
			v23y = sin(a) * (@radius)

			# d = if (i < length * 0.5) then i * 0.01 else (length - 4 - i) * 0.01
			# slice =  TWO_PI / length
			# d = (cos(i * slice) + 1) * 0.5
			# d *= 0.1
			d = 0

			TweenLite.to(v0, t, { x:v01x, y:v01y, delay:d, ease:Quart.easeIn })
			TweenLite.to(v1, t, { x:v01x, y:v01y, delay:d, ease:Quart.easeIn })
			TweenLite.to(v2, t, { x:v23x, y:v23y, delay:d, ease:Quart.easeIn })
			TweenLite.to(v3, t, { x:v23x, y:v23y, delay:d, ease:Quart.easeIn })

		TweenLite.delayedCall(t, => @morphing = false )

		return null
	###