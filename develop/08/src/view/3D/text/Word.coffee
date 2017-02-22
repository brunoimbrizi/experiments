class Word

	mesh 					: null
	geometry				: null
	material				: null

	index					: null
	label					: null


	constructor: (@index, @label) ->
		@texture = THREE.ImageUtils.loadTexture('textures/' + @label + '.png')
		@material = new THREE.MeshLambertMaterial({ map: @texture, color: 0xffffff, ambient: 0x777777, transparent: true })
		@geometry = new THREE.PlaneGeometry(130, 26, 2, 2)
		@mesh = new THREE.Mesh(@geometry, @material)

		@mesh.scale = new THREE.Vector3(0.12, 0.12, 0.12)
		@mesh.visible = false
		# @mesh.rotation.x = HALF_PI - TWO_PI
		# @mesh.rotation.z = PI
		# @mesh.position.x = -60 - @geometry.width * @mesh.scale.x

		# window.app.view.three.scene.add(@mesh)

		# @initMesh()