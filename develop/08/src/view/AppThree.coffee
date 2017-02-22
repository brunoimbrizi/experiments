class AppThree

	view 					: null

	camera 					: null
	scene 					: null
	renderer 				: null
	projector 				: null
	controls				: null

	container				: null
	plane 					: null
	bars 					: null

	mouse 					: null
	offset 					: null
	selected 				: null
	interactiveObjects		: null

	lightA					: null
	lightB					: null
	lightC					: null
	lightD					: null

	iniQ 					: null
	endQ 					: null
	curQ 					: null
	vec3 					: null
	tweenObj 				: null
	cameraPos0 				: null
	cameraUp0	 			: null
	cameraZoom	 			: null


	constructor: ->
		@view = app.view
		@renderer = @view.renderer

		@mouse = new THREE.Vector2()
		@offset = new THREE.Vector3()

		# @hw = @view.sketch.width * .5
		# @hh = @view.sketch.height * .5

		@initThree()
		@initObject()
		@initLights()
		@initControls()
		# @initInteractiveObjects()
		# @initPostProcessing()

		window.addEventListener(AppAudio.EVENT_AUDIO_RESTARTED, @onAudioRestarted)


	initThree: ->
		# scene
		@scene = new THREE.Scene()

		# projector
		@projector = new THREE.Projector()

		# camera
		@camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 1, 2000)
		@camera.position = new THREE.Vector3(0, 0, 80)
		@cameraPos0 = @camera.position.clone()
		@cameraUp0 = @camera.up.clone()
		@cameraZoom = @camera.position.z

		# objects
		@container = new THREE.Object3D()
		@scene.add(@container)

		# grid
		# plane = new THREE.Mesh(new THREE.PlaneGeometry(400, 400, 20, 20), new THREE.MeshBasicMaterial( { color:0x444444, wireframe:true }))
		# @container.add(plane)


	initLights: ->
		# lights
		@lightA = new THREE.DirectionalLight( 0xff0000 )
		@lightA.position.set( 0, 0, 10 )
		@lightA.intensity = 1
		# @lightA = new THREE.PointLight( 0xffffff )
		# @lightA.position.set( 0, 50, 10 )
		@scene.add(@lightA)

		@lightB = new THREE.PointLight( 0xff0000 )
		@lightB.position.set( 0, -50, 10 )
		@scene.add(@lightB)

		@lightC = new THREE.AmbientLight( 0xffffff )
		@lightC.visible = false
		@scene.add(@lightC)

		# debug lights
		sphereGeometry = new THREE.SphereGeometry(0.5, 10, 10)
		sphereMaterial = new THREE.MeshBasicMaterial({ color: 0xff0000 })
		@lightViewA = new THREE.Mesh(sphereGeometry, sphereMaterial)
		@lightViewA.position = @lightA.position
		# @scene.add(@lightViewA)

		sphereMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff })
		@lightViewB = new THREE.Mesh(sphereGeometry, sphereMaterial)
		@lightViewB.position = @lightB.position
		# @scene.add(@lightViewB)


	initControls: ->
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
		@controls.noPan = true
		@controls.noZoom = true

		@controls.enabled = false


	initObject: ->
		@bars = new AudioBars()
		@bars.container.rotation.x = HALF_PI
		@scene.add(@bars.container)

		@lyrics = new Lyrics()
		@scene.add(@lyrics.hello)
		@scene.add(@lyrics.howlow)


	initInteractiveObjects: ->
		@interactiveObjects = []
		
		drag = new Drag()
		# drag.mesh.visible = false
		@interactiveObjects.push(drag.mesh)
		# @scene.add(drag.mesh)

		# @lightD.position = drag.mesh.position


	initPostProcessing: ->
		@dotScreenShader = new THREE.ShaderPass(THREE.DotScreenShader)
		@dotScreenShader.uniforms['scale'].value = 4
		# dotScreenShader.material.transparent = true
		@dotScreenShader.renderToScreen = true

		@dotMatrixShader = new THREE.ShaderPass(THREE.DotMatrixShader)
		@dotMatrixShader.renderToScreen = true

		@filmShader = new THREE.ShaderPass(THREE.FilmShader)
		@filmShader.uniforms['grayscale'].value = 0
		@filmShader.renderToScreen = true

		renderTargetParams = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBAFormat }
		renderTarget = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight, renderTargetParams)
		
		@composer = new THREE.EffectComposer(@renderer, renderTarget)
		# @composer = new THREE.EffectComposer(@renderer)
		@composer.addPass(new THREE.RenderPass(@scene, @camera))
		# @composer.addPass(@dotScreenShader)
		# @composer.addPass(@dotMatrixShader)
		@composer.addPass(@filmShader)

		@shaderTime = 0


	# ---------------------------------------------------------------------------------------------
	# PUBLIC
	# ---------------------------------------------------------------------------------------------

	update: ->
		if !@renderer then return
		if @controls then @controls.update()

		values = app.audio.values.slice(@view.ui.iniBin, @view.ui.endBin)
		@bars.update(values)

		@lyrics.update(values)

		if(@lightB.userData.updateWithAudio)
			@lightB.position.y = MathUtils.map(app.audio.values[10], 0, 1, 20, -50)

		# @shaderTime += 0.1
		# @filmShader.uniforms['time'].value = @shaderTime

		return


	draw: ->
		# if !@renderer then return
		@renderer.render(@scene, @camera)
		# @composer.render()

		return


	setState: (state = 0) ->
		state = parseInt(state)
		euler = new THREE.Euler()
		@endQ = new THREE.Quaternion()
		@iniQ = new THREE.Quaternion().copy(@camera.quaternion)
		@curQ = new THREE.Quaternion()
		@vec3 = new THREE.Vector3()
		@tweenObj = { value:0 }

		switch (state)
			# ZOOM OUT SLOWLY
			when 0 
				TweenLite.to(@, 14, { cameraZoom:150, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })

			# REVEAL SPHERE
			when 1
				# rotation captured manually with trackball controls
				# e.g. 		euler = new THREE.Euler().setFromQuaternion(app.view.three.camera.quaternion)
				# better: 	euler = app.view.three.camera.rotation.clone()

				# set end quaternion from euler
				@endQ.setFromEuler(new THREE.Euler(2.20, -0.15, 0.55))
				# tween value and slerp quaternion on update
				TweenLite.to(@tweenObj, 8, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 5, { y:-50, z:-50, ease:Quart.easeInOut })

				_gaq.push(['_trackEvent', 'state', 'reveal-sphere'])

			# SHOW TARGET
			when 2
				@endQ.setFromEuler(new THREE.Euler(2.50, 0.08, -0.75))
				TweenLite.to(@tweenObj, 3, { value:1, ease:Quart.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 3, { y:-50, z:10, ease:Quart.easeInOut })

			# ROTATE TARGET
			when 3
				# @endQ.setFromEuler(new THREE.Euler(2.83, -0.45, -0.37))
				@endQ.setFromEuler(new THREE.Euler(2.35, -0.35, -0.25))
				TweenLite.to(@tweenObj, 5, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })

			# ROTATE TARGET / MOVE LIGHT TO CENTER
			when 4
				@endQ.setFromEuler(new THREE.Euler(2.56, 0.15, 2.99))
				TweenLite.to(@tweenObj, 5, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightA.position, 4, { y:0, z:-10, ease:Quart.easeInOut })
				TweenLite.to(@lightB.position, 2, { y:10, z:0, delay:1.2, ease:Quart.easeInOut })
				TweenLite.to(@, 8, { cameraZoom:120, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })

			# ROTATE TARGET
			when 5
				@endQ.setFromEuler(new THREE.Euler(0.85, 0.25, -3.00))
				# @endQ.setFromEuler(new THREE.Euler(2.46, 0.44, -3.12))
				TweenLite.to(@tweenObj, 6, { value:1, ease:Sine.easeIn, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightA, 3, { intensity:0, ease:Quart.easeInOut })
				TweenLite.to(@lightB.position, 5, { y:-40, z:10, ease:Quart.easeInOut })

			# SHOW CYLINDER
			when 6
				@endQ.setFromEuler(new THREE.Euler(0.46, 0.40, -3.06))
				TweenLite.to(@tweenObj, 5, { value:1, ease:Sine.easeOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 5, { y:-40, z:10, ease:Quart.easeInOut })
				TweenLite.to(@, 6, { cameraZoom:150, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })

			# ROTATE CYLINDER
			when 7
				@endQ.setFromEuler(new THREE.Euler(2.56, -1.25, -0.98))
				TweenLite.to(@tweenObj, 9, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })

			# ROTATE CYLINDER
			when 8
				@endQ.setFromEuler(new THREE.Euler(1.32, -0.88, -1.45))
				TweenLite.to(@tweenObj, 10, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 6, { cameraZoom:100, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })

			# ROTATE CYLINDER
			when 9
				@endQ.setFromEuler(new THREE.Euler(1.25, -1.25, -1.48))
				TweenLite.to(@tweenObj, 8, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 4, { cameraZoom:80, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 5, { y:-50, z:0, ease:Quart.easeInOut })

			# CYLINDER FROM TOP
			when 10
				@endQ.setFromEuler(new THREE.Euler(HALF_PI, 0.00, -HALF_PI))
				TweenLite.to(@tweenObj, 4, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 8, { cameraZoom:120, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })

				@lightB.userData.updateWithAudio = true

			# ZOOM IN CYLINDER
			when 11
				TweenLite.to(@, 4, { cameraZoom:18, ease:Back.easeIn, onUpdate:@onSlerpUpdate })

				@lightB.userData.updateWithAudio = false

			# ZOOM OUT HELLO
			when 12
				# @endQ.setFromEuler(new THREE.Euler(-1.55, -0.04, 1.65))
				# TweenLite.to(@tweenObj, 3, { value:1, ease:Quart.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 7, { cameraZoom:200, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })


			# ZOOM IN HOW LOW
			when 13
				@endQ.setFromEuler(new THREE.Euler(2.46, -0.06, -1.95))
				TweenLite.to(@tweenObj, 8, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 2, { cameraZoom:40, ease:Quart.easeInOut, delay:3.0, onUpdate:@onSlerpUpdate })

			# ROTATE HOW LOW
			when 14
				@endQ.setFromEuler(new THREE.Euler(-3.07, -0.36, -1.54))
				TweenLite.to(@tweenObj, 10, { value:1, ease:Sine.easeIn, onUpdate:@onSlerpUpdate })

			# SHOW STRAIGHT BARS
			when 15
				# @endQ.setFromEuler(new THREE.Euler(0.00, -1.45, HALF_PI))
				@endQ.setFromEuler(new THREE.Euler(-1.22, 0.14, 1.30))
				TweenLite.to(@tweenObj, 22, { value:1, ease:Sine.easeOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 4, { y:6, z:0, ease:Quart.easeInOut })

			# AFTER SILENCE
			when 16
				@endQ.setFromEuler(new THREE.Euler(-2.95, 0.00, 1.74))
				TweenLite.to(@tweenObj, 0.1, { value:1, ease:Sine.easeOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 0.1, { cameraZoom:80, ease:Quart.easeInOut, onUpdate:@onSlerpUpdate })

			# ROTATE STRAIGHT BARS
			when 17
				@endQ.setFromEuler(new THREE.Euler(2.65, -0.55, 1.70))
				TweenLite.to(@tweenObj, 8, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 8, { y:-50, z:-10, ease:Sine.easeInOut })

			# ROTATE MORE STRAIGHT BARS
			when 18
				@endQ.setFromEuler(new THREE.Euler(0.50, 0.0, 2.90))
				TweenLite.to(@tweenObj, 12, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })

			# ROTATE MORE STRAIGHT BARS
			when 19
				@endQ.setFromEuler(new THREE.Euler(0.55, 0.58, 1.33))
				TweenLite.to(@tweenObj, 10, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 8, { cameraZoom:40, ease:Quart.easeInOut, onUpdate:@onSlerpUpdate })

			# ZOOM OUT SPHERE
			when 20
				TweenLite.to(@, 2, { cameraZoom:130, ease:Quart.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 2, { y:-100, z:0, ease:Sine.easeInOut })
				TweenLite.to(@lightA, 2, { intensity:1, ease:Quart.easeInOut })

			# ROTATE SPHERE
			when 21
				@endQ.setFromEuler(new THREE.Euler(1.90, 1.10, 0.85))
				TweenLite.to(@tweenObj, 15, { value:1, ease:Quart.easeInOut, onUpdate:@onSlerpUpdate })

			# ROTATE CYLINDER
			when 22
				# @endQ.setFromEuler(new THREE.Euler(2.30, 0.75, 0.09))
				@endQ.setFromEuler(new THREE.Euler(0.40, 0.17, -2.67))
				TweenLite.to(@tweenObj, 14.5, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 14, { cameraZoom:80, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 2, { y:-20, ease:Sine.easeInOut })
				TweenLite.to(@lightA, 2, { intensity:0, ease:Quart.easeInOut })

			# ROTATE CYLINDER
			when 23
				@endQ.setFromEuler(new THREE.Euler(2.60, -0.15, 0.07))
				TweenLite.to(@tweenObj, 18, { value:1, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@, 15, { cameraZoom:120, ease:Sine.easeInOut, onUpdate:@onSlerpUpdate })
				TweenLite.to(@lightB.position, 8, { y:-50, ease:Sine.easeInOut })



	# ---------------------------------------------------------------------------------------------
	# EVENT HANDLERS
	# ---------------------------------------------------------------------------------------------

	onSlerpUpdate: =>
		THREE.Quaternion.slerp(@iniQ, @endQ, @curQ, @tweenObj.value)

		@vec3.x = @cameraPos0.x
		@vec3.y = @cameraPos0.y
		@vec3.z = @cameraZoom
		@vec3.applyQuaternion(@curQ)
		@camera.position.copy(@vec3)

		@vec3 = @cameraUp0.clone()
		@vec3.applyQuaternion(@curQ)
		@camera.up.copy(@vec3)

		return


	onAudioRestarted: (e) =>
		@camera.position.copy(@cameraPos0)
		@camera.up.copy(@cameraUp0)
		@cameraZoom = @camera.position.z

		@lightA.position.set( 0, 0, 10 )
		@lightB.position.set( 0, -50, 10 )
		@lightA.intensity = 1

		@lyrics.restart()
		@scene.add(@lyrics.hello)
		@scene.add(@lyrics.howlow)

		return
		

	resize: ->
		if !@renderer then return
		@camera.aspect = @view.sketch.width / @view.sketch.height
		@camera.updateProjectionMatrix();

		@renderer.setSize(@view.sketch.width, @view.sketch.height)

		@hw = @view.sketch.width * .5
		@hh = @view.sketch.height * .5

		return