class AppUI

	view 					: null

	drawImage 				: false
	lineWidthRandom 		: true
	lineWidthBrightness		: true
	tint 					: false
	drawNegative			: false
	threshold 				: 100
	lineWidth 				: 5
	scale 					: 2
	numCircles				: 80
	numFrames				: 180
	numSlices				: 60
	easing 					: 'easeInCirc'
	image 					: 'william.jpg'
	color 					: '#00cc25'
	redraw	 				: null


	constructor: ->
		@view = app.view

		@initGUI()
		# @initStats()


	initGUI: ->
		@redraw = ->
			@view.redraw()

		gui = new dat.GUI({ load:window.presets })
		gui.open()
		gui.remember(@)
		that = @

		# f1 = gui.addFolder('Draw')
		# f1.open()
		# f1.add(@, 'drawImage')
		# f1.add(@, 'drawNegative')
		gui.add(@, 'tint')
		gui.addColor(@, 'color')
		gui.add(@, 'lineWidthRandom')
		gui.add(@, 'lineWidthBrightness')
		gui.add(@, 'lineWidth', 1, 10)
		gui.add(@, 'threshold', 0, 255)
		gui.add(@, 'scale', 0.5, 5)
		gui.add(@, 'numCircles', 10, 100)
		gui.add(@, 'numFrames', 10, 540)
		gui.add(@, 'numSlices', 5, 120)
		gui.add(@, 'easing', [ 'easeLinear', 'easeInQuad', 'easeOutQuad', 'easeInOutQuad', 'easeInCubic', 'easeOutCubic', 'easeInOutCubic', 'easeInQuart', 'easeOutQuart', 'easeInOutQuart', 'easeInQuint', 'easeOutQuint', 'easeInOutQuint', 'easeInSine', 'easeOutSine', 'easeInOutSine', 'easeInExpo', 'easeOutExpo', 'easeInOutExpo', 'easeInCirc', 'easeOutCirc', 'easeInOutCirc' ] )
		# gui.add(@, 'image', [ 'charlotte-le-bon.jpg', 'william.jpg', 'dude.jpg', 'marley.jpg', 'godfather.jpg', 'godfather_black.jpg', 'nine.gif', 'skull.jpg', 'tesla.jpg' ] ).onChange(-> that.onImageChange())
		gui.add(@, 'image').onChange(-> that.onImageChange())
		gui.add(@, 'redraw')

		# add preset passed in via url param
		param = app.getParam('p')
		if param then gui.preset = param

		return null



	initStats: ->
		@stats = new Stats();
		document.body.appendChild(@stats.domElement)

		return null


	onImageChange: ->
		@view.image.src = 'img/' + @image

		return null