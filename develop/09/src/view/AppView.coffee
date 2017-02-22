class AppView

	sketch 					: null

	img						: null
	circles					: null


	init: ->
		@initSketch()


	initSketch: =>
		@sketch = Sketch.create
			type			: Sketch.CANVAS
			container 		: document.getElementById('container')
			autoclear 		: false


		@sketch.setup = =>
			@initImage()
			@initUI()
			# @sketch.resize()

			@frameCount = 0

			return null


		@sketch.update = =>
			if (!@iw) then return

			@frameCount++

			return null


		@sketch.draw = =>
			if (!@iw) then return

			# @ui.stats.begin()
			@sketch.save()
			@sketch.translate(@cx, @cy)

			# image
			ihw = @iw * 0.5
			ihh = @ih * 0.5
			if (@ui.drawImage) then @sketch.drawImage(@img, -ihw, -ihh)

			# circles
			@sketch.strokeStyle = @ui.color
			@sketch.lineWidth = @ui.lineWidth
			if (@frameCount < @ui.numFrames)
				for c in @circles
					slice = TWO_PI / @ui.numSlices

					i = @frameCount * c.time
					iniAngle = c.iniAngle + i * slice
					endAngle = c.iniAngle + (i + 1) * slice
					colors = @getColors(ihw + c.radius * cos(iniAngle), ihh + c.radius * sin(iniAngle))

					if (@ui.drawNegative)
						if (colors.gray > @ui.threshold) then continue
					else
						if (colors.gray < @ui.threshold) then continue

					if(!@ui.tint) then @sketch.strokeStyle = 'rgb(' + colors.r + ',' + colors.g + ',' + colors.b + ')'

					if (@ui.lineWidthRandom) then @sketch.lineWidth = random(@ui.lineWidth)
					else if (@ui.lineWidthBrightness)
						thickness = (255 - @ui.threshold) / @ui.lineWidth
						@sketch.lineWidth = floor((colors.gray - @ui.threshold) / thickness)

					@sketch.beginPath()
					@sketch.arc(0, 0, c.radius * @ui.scale, iniAngle, endAngle)
					@sketch.stroke()
					@sketch.closePath()

			@sketch.restore()
			# @ui.stats.end()


			return null


		@sketch.resize = =>
			@ix = floor((@sketch.width - @iw)  * 0.5)
			@iy = floor((@sketch.height - @ih)  * 0.5)

			@cx = floor(@sketch.width * 0.5)
			@cy = floor(@sketch.height * 0.5)

			if (@frameCount > @ui.numFrames) then @redraw()

			return null


		@sketch.keyup = (e) =>
			return null


		@sketch.mousedown = =>
			return null


		@sketch.mousemove = =>
			return null


		@sketch.mouseup = =>
			return null


	initUI: =>
		@ui = new AppUI()

		return null


	initImage: =>
		@image = new Image()
		@image.onload = =>
			@iw = @image.width
			@ih = @image.height

			@img = document.createElement('canvas')
			@img.width = @iw
			@img.height = @ih
			@img.ctx = @img.getContext('2d')
			@img.ctx.drawImage(@image, 0, 0)

			@sketch.clear()
			@frameCount = 0
			@initCircles()
			@setColors()
		# @image.src = 'img/charlotte.gif'
		# @image.src = 'img/charlotte-le-bon.jpg'
		@image.src = 'img/william.jpg'
		# @image.src = 'img/tesla.jpg'
		# @image.src = 'img/rgb.gif'
		# @image.src = 'img/abide.gif'
		# @image.src = 'img/nine_centred.gif'

		###
		@img = new Image()
		@img.onload = =>
			@iw = @img.width
			@ih = @img.height
			@setColors()
		@img.src = 'img/abide.gif'
		###

		return null


	setColors: ->
		# store brightness values in an array
		data = @img.ctx.getImageData(0, 0, @img.width, @img.height).data
		size = @img.width * @img.height
		i = 0

		@colors = []
		for i in [0...size]
			# store only red value, since img is b&w
			o = {}
			o.r = data[4 * i]
			o.g = data[4 * i + 1]
			o.b = data[4 * i + 2]
			o.gray = (o.r + o.g + o.b) / 3
			@colors.push(o)

		return null


	getColors: (x, y) ->
		black = { r:0, g:0, b:0, gray:0 }

		if (x > @img.width || x < 0) then return black
		if (y > @img.height || y < 0) then return black

		index = floor(y) * @img.width + floor(x)
		if (index > @colors.length) then return black

		return @colors[index]


	initCircles: =>
		@circles = []

		num = @ui.numCircles
		for i in [0...num]
			iniRadius = 1
			endRadius = max(@iw, @ih) / 2

			r = Math[@ui.easing](i, iniRadius, endRadius, num)

			c = {}
			c.iniAngle = random(TWO_PI)
			# c.radius = i * 10
			c.index = i
			c.radius = r
			c.angle = 0
			c.time = 0
			@circles.push(c)

			# TweenMax.to(c, 1, { angle:TWO_PI, delay:(num - i) * 0.1, ease:Circ.easeInOut })
			TweenMax.to(c, 3, { time:1, delay:random(), ease:Circ.easeOut })

		return null


	redraw: =>
		@sketch.clear()

		@frameCount = 0
		@initCircles()

		return null
