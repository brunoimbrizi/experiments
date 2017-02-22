class AppUI

	view 					: null
	audio 					: null

	stats 					: null

	canvas 					: null
	ctx 					: null
	player 					: null
	loader					: null
	barChart 				: null

	barCirc 				: null
	barThickness			: null
	barDepth				: null
	barWireframe			: false
	morph					: null

	lightA					: true
	lightB					: true
	lightC					: false
	lightD					: true
	lightB_y				: null
	lightB_z				: null
	lightA_y				: null
	lightA_z				: null

	scene 					: null

	iniBin 					: null
	endBin 					: null
	mute 					: false

	cameraFOV 				: null

	drawBarChart 			: false
	phi			 			: null
	theta		 			: null

	dotScale 				: null
	dotSpacing 				: null
	filmSCount 				: null
	filmSIntensity			: null
	filmNIntensity			: null


	constructor: ->
		@view = app.view
		@audio = app.audio

		@barCirc = 1
		@barThickness = 4
		@barDepth = 2
		@morph = @onMorphClick
		@scene = 0
		@cameraFOV = 50
		@iniBin = 30
		@endBin = 60
		@phi = 0
		@theta = 0
		@lightA_y = 0
		@lightA_z = 10
		@lightB_y = -50
		@lightB_z = 10
		@dotSpacing = 10
		@dotScale = 4
		@filmSCount = 4096
		@filmSIntensity = 0.05
		@filmNIntensity = 0.5

		# @initGUI()
		# @initStats()
		@initCanvas()
		@initPlayer()
		@initLoader()
		@initBarChart()


	initGUI: ->
		gui = new dat.GUI()
		gui.close()
		that = @

		f1 = gui.addFolder('Bars')
		# f1.open()
		f1.add(@, 'barCirc', 0, 1).step(0.1).onChange(-> that.onBarCircChange())
		f1.add(@, 'barThickness', 1, 10).step(0.5).onChange(-> that.onBarThicknessChange())
		f1.add(@, 'barDepth', 1, 10).step(0.5).onChange(-> that.onBarDepthChange())
		f1.add(@, 'barWireframe').onChange(-> that.onBarWireframeChange())

		f2 = gui.addFolder('Lights')
		# f2.open()
		f2.add(@, 'lightA').onChange(-> that.onLightChange())
		f2.add(@, 'lightB').onChange(-> that.onLightChange())
		f2.add(@, 'lightC').onChange(-> that.onLightChange())
		
		f2.add(@, 'lightA_y', -100, 100).onChange(-> that.onLightChange())
		f2.add(@, 'lightA_z', -100, 100).onChange(-> that.onLightChange())
		f2.add(@, 'lightB_y', -100, 100).onChange(-> that.onLightChange())
		f2.add(@, 'lightB_z', -100, 100).onChange(-> that.onLightChange())

		f3 = gui.addFolder('Scenes')
		f3.open()
		f3.add(@, 'scene', ['0', '1', '2', '3', '4', '5', '6', '7']).onChange(-> that.onSceneChange())

		f4 = gui.addFolder('Audio')
		f4.open()
		f4.add(@, 'iniBin', 0, @audio.BINS).step(1)
		f4.add(@, 'endBin', 0, @audio.BINS).step(1)
		f4.add(@, 'mute').onChange(-> that.onMuteChange())

		f5 = gui.addFolder('Shaders')
		# f5.open()
		f5.add(@, 'dotSpacing', 0, 30).onChange(-> that.onShaderChange())
		f5.add(@, 'dotScale', 0, 10).onChange(-> that.onShaderChange())
		f5.add(@, 'filmSCount', 50, 10000).onChange(-> that.onShaderChange())
		f5.add(@, 'filmSIntensity', 0.0, 2.0).onChange(-> that.onShaderChange())
		f5.add(@, 'filmNIntensity', 0.0, 2.0).onChange(-> that.onShaderChange())

		f6 = gui.addFolder('Debug')
		# f6.open()
		f6.add(@, 'drawBarChart')
		f6.add(@, 'phi', -PI, PI).step(0.1)
		f6.add(@, 'theta', -HALF_PI, HALF_PI).step(0.1)


	initStats: ->
		@stats = new Stats();
		document.body.appendChild(@stats.domElement)


	initCanvas: ->
		@canvas = document.getElementById('canvasUI')
		@canvas.width = @view.sketch.width
		@canvas.height = @view.sketch.height
		@ctx = @canvas.getContext('2d')


	initPlayer: ->
		@player = new PlayerView(@ctx)


	initLoader: ->
		@loader = new LoaderView()


	initBarChart: =>
		@barChart = new BarChartView(@ctx)


	onBarCircChange: ->
		for bar in @view.three.bars.bars
			bar.circ = @barCirc


	onBarThicknessChange: ->
		for bar in @view.three.bars.bars
			bar.thickness = @barThickness


	onBarDepthChange: ->
		for bar in @view.three.bars.bars
			bar.depth = @barDepth


	onBarWireframeChange: ->
		for bar in @view.three.bars.bars
			bar.material.wireframe = @barWireframe


	onMorphClick: ->
		for bar in @view.three.bars.bars
			if (bar.circ == 1) then TweenLite.to(bar, 0.4, { circ:0 })
			else TweenLite.to(bar, 0.4, { circ:1 })


	onLightChange: ->
		@view.three.lightA.visible = @lightA
		@view.three.lightB.visible = @lightB
		@view.three.lightC.visible = @lightC

		@view.three.lightA.position.y = @lightA_y
		@view.three.lightA.position.z = @lightA_z
		@view.three.lightB.position.y = @lightB_y
		@view.three.lightB.position.z = @lightB_z


	onSceneChange: ->
		# @view.three.bars.changeScene(@scene)
		@view.three.bars.setState(@scene)

		# if (@scene == '5') then @view.three.setState(12)


	onMuteChange: ->
		if (@mute) then	@audio.analyserNode.disconnect()
		else @audio.analyserNode.connect(@audio.ctx.destination)


	onCameraChange: ->
		@view.three.camera.fov = @cameraFOV
		@view.three.camera.updateProjectionMatrix()


	onShaderChange: ->
		# @view.three.dotScreenShader.uniforms['scale'].value = @dotScale
		# @view.three.dotMatrixShader.uniforms['spacing'].value = @dotSpacing
		# @view.three.dotMatrixShader.uniforms['size'].value = @dotScale
		@view.three.filmShader.uniforms['sCount'].value = @filmSCount
		@view.three.filmShader.uniforms['sIntensity'].value = @filmSIntensity
		@view.three.filmShader.uniforms['nIntensity'].value = @filmNIntensity


	# ---------------------------------------------------------------------------------------------
	# PUBLIC
	# ---------------------------------------------------------------------------------------------

	update: ->
		@player.update()
		@barChart.update(@audio.values, @iniBin, @endBin)


	draw: ->
		@ctx.clearRect(0, 0, @view.sketch.width, @view.sketch.height)
		@player.draw()
		if (@drawBarChart) then @barChart.draw()


	resize: ->
		@canvas.width = @view.sketch.width
		@canvas.height = @view.sketch.height


	touchstart: =>
		@player.touchstart()


	touchmove: =>
		@player.touchmove()