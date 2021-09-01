class AppThree

	view 					: null

	camera 					: null
	scene 					: null
	renderer 				: null
	projector 				: null
	controls				: null

	container				: null

	mouse 					: null
	interactiveObjects		: null
	selectedMatrix			: null
	selectedOffset			: null
	intersected				: null

	lines					: null


	constructor: ->
		@view = app.view
		@mouse = { x:0, y:0 }
		@hw = @view.sketch.width * .5
		@hh = @view.sketch.height * .5

		@initThree()
		@initLines()
		@initInteractiveObjects()


	initThree: ->
		# scene
		@scene = new THREE.Scene()
		@scene.fog = new THREE.Fog( 0x232323, 1, 2000 )
		# @scene.fog = new THREE.Fog( 0xffffff, 1, 2000 )

		# lights
		light = new THREE.DirectionalLight( 0x666666 )
		light.position.set( 0, 2, 1 )
		@scene.add(light)

		ambientLight = new THREE.AmbientLight( 0x111111 )
		@scene.add( ambientLight )

		# renderer
		@renderer = new THREE.WebGLRenderer(canvas:@view.sketch.canvas)
		@renderer.setSize(@view.sketch.width, @view.sketch.height)

		# projector
		@projector = new THREE.Projector()

		# camera
		@camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.01, 2000)
		@camera.position = new THREE.Vector3(0, 0, 600)

		# trackball
		@controls = new THREE.TrackballControls(@camera, @renderer.domElement)
		@controls.target.set(0, 0, 0)
		@controls.rotateSpeed = 1.0
		@controls.zoomSpeed = 0.8
		@controls.panSpeed = 0.8
		@controls.noZoom = false
		@controls.noPan = false
		@controls.staticMoving = false
		@controls.dynamicDampingFactor = 0.15
		@controls.maxDistance = 3000

		# objects
		@container = new THREE.Object3D()
		@scene.add(@container)

		# grid
		# plane = new THREE.Mesh(new THREE.PlaneGeometry(400, 400, 20, 20), new THREE.MeshBasicMaterial( { color:0x444444, wireframe:true }))
		# @container.add(plane)


	initLines: ->
		@lines = []
		for lineModel in app.lines.models
			line = new LineView(new THREE.Object3D(), lineModel, @lines.length)
			@container.add(line.container)
			@lines.push(line)
			# if (@lines.length > 2) then return


	initInteractiveObjects: ->
		@interactiveObjects = []
		for line in @lines
			for station in line.stations
				@interactiveObjects.push(station)



	# ---------------------------------------------------------------------------------------------
	# PUBLIC
	# ---------------------------------------------------------------------------------------------

	update: ->
		if !@renderer then return
		@controls.update()

		if @selectedMatrix
			matrix = @selectedMatrix
			if (@selectedOffset)
				matrix = new THREE.Matrix4().copy(@selectedMatrix)
				matrix.elements[14] += @selectedOffset
			vec = @projector.projectVector(new THREE.Vector3().getPositionFromMatrix(matrix), @camera)
			vec.x = (vec.x * @hw) + @hw
			vec.y = -(vec.y * @hh) + @hh

			offset = -5

			@view.ui.label.pos.x = floor(vec.x)
			@view.ui.label.pos.y = floor(vec.y) + offset


	draw: ->
		if !@renderer then return
		@renderer.render(@scene, @camera)


	# ---------------------------------------------------------------------------------------------
	# EVENT HANDLERS
	# ---------------------------------------------------------------------------------------------

	resize: ->
		if !@renderer then return
		@camera.aspect = @view.sketch.width / @view.sketch.height
		@camera.updateProjectionMatrix();

		@renderer.setSize(@view.sketch.width, @view.sketch.height)

		@hw = @view.sketch.width * .5
		@hh = @view.sketch.height * .5


	mousedown: (e) ->
		e.preventDefault()

		@controls.enabled = true

		# use raycaster to find if mouse is hitting a station
		vec = new THREE.Vector3(@mouse.x, @mouse.y, 0.5)
		@projector.unprojectVector(vec, @camera)

		raycaster = new THREE.Raycaster(@camera.position, vec.sub(@camera.position).normalize())
		intersects = raycaster.intersectObjects(@interactiveObjects)

		if (intersects.length > 0)
			for intersect in intersects
				selected = intersect.object
				if (@lines[selected.lineIndex].enabled) then break
			if (!@lines[selected.lineIndex].enabled) then return
			@controls.enabled = false
			@view.ui.toggleLabel(selected)

			

	mousemove: (e) ->
		@mouse.x = (e.clientX / window.innerWidth) * 2 - 1
		@mouse.y = - (e.clientY / window.innerHeight) * 2 + 1


	mouseup: (e) ->
		e.preventDefault()

		@controls.enabled = true