init = ->
	sketch = Sketch.create

		boids 			: null
		img 			: null
		brightness 		: null
		down			: null
		drawImg			: false
		drawLines		: true
		cohesion		: false
		numBoids		: 0

		NUM_BOIDS		: 100

		container: document.getElementById 'container'


		setup: ->
			@numBoids = @NUM_BOIDS

			@initBoids()
			@initImage()
			@initGUI()

			if parent.app then parent.app.updateBodyClass('black')


		update: ->
			if @img
				ix = (sketch.width - @img.width) * .5
				iy = (sketch.height - @img.height) * .5

			# add or remove boids
			diffBoids = @numBoids - @boids.length
			if (diffBoids > 0)
				for i in [0...diffBoids]
					@addBoid()
			else if (diffBoids < 0)
				diffBoids *= -1
				for i in [0...diffBoids]
					@boids.pop()

			# draw lines only up to 150 boids
			# if @numBoids > 150 then @drawLines = false

			i = 0
			for boid in @boids
				if @down then boid.acc.addSelf(boid.seek(new Vec3D(sketch.mouse.x, sketch.mouse.y, 0)).scaleSelf(0.1))
				boid.acc.addSelf(boid.separate(@boids))
				if @cohesion then boid.acc.addSelf(boid.cohesion(@boids).scaleSelf(0.001))
				if (i < @numBoids * .5) then boid.acc.addSelf(boid.seek(new Vec3D(sketch.width * .5, sketch.height * .4, 0)).scaleSelf(0.002))
				else boid.acc.addSelf(boid.seek(new Vec3D(sketch.width * .5, sketch.height * .6, 0)).scaleSelf(0.002))
				boid.update()
				boid.bounce()
				i++

				if !@img then continue

				##
				# if boid is over the image
				if (boid.pos.x > ix && boid.pos.x < ix + @img.width && boid.pos.y > iy && boid.pos.y < iy + @img.height)
					# if boid is already over a drawLine area, skip
					brightness = @getBrightness(boid.pos.x - ix, boid.pos.y - iy)
					# console.log 'over', brightness, floor(boid.pos.x - ix), floor(boid.pos.y - iy)
					boid.drawLine = false
					if (brightness > 200)
						boid.drawLine = true
						continue

					##
					slice = TWO_PI / 4
					va = atan2(boid.vel.y, boid.vel.x)
					range = 20
					
					# check the brightness of some points around the boid
					for a in [1...4]
						ax = cos(va - a * slice) * range
						ay = sin(va - a * slice) * range
						ex = boid.pos.x + ax - ix
						ey = boid.pos.y + ay - iy
						# if the point is outside the image, skip
						if (ex < 0 || ex > @img.width || ey < 0 || ey > @img.height) then continue
						brightness = @getBrightness(ex, ey)
						# if the point is on a bright area, seek that point
						if (brightness > 200)
							boid.acc.addSelf(boid.seek(new Vec3D(boid.pos.x + ax, boid.pos.y + ay, 0)).scaleSelf(0.3))
					##
				##


		draw: ->
			# sketch.globalCompositeOperation  = 'lighter'

			if @img && @drawImg
				ix = (sketch.width - @img.width) * .5
				iy = (sketch.height - @img.height) *.5
				sketch.drawImage(@img, ix, iy)

			for boid in @boids
				boid.draw()

			if !@drawLines then return
			# if @numBoids > 150 then return

			for i in [0...@numBoids]
				boid = @boids[i]
				if (boid.drawLine)
					# sketch.beginPath()
					for j in [i...@numBoids]
						other = @boids[j]
						if boid == other then continue
						distance = floor(boid.pos.distanceTo(other.pos))
						if (distance < 60)
							sketch.moveTo(boid.pos.x, boid.pos.y)
							sketch.lineTo(other.pos.x, other.pos.y)
							# sketch.strokeStyle = 'rgba(255, 0, 84, 0.2)'
							# sketch.strokeStyle = 'rgba(255, 0, 84, ' + (0.5 - (distance / 80)) + ')'
							# sketch.stroke()

			sketch.strokeStyle = 'rgba(255, 0, 84, 0.3)'
			sketch.stroke()
			

		mousedown: ->
			@down = true


		mouseup: ->
			@down = false


		keydown: (e) ->
			txt = String.fromCharCode(e.keyCode)

			@img.width = @img.width
			@img.ctx.font = "380px Monda"
			@img.ctx.fillStyle = '#fff'
			@img.ctx.fillText(txt, (@img.width - @img.ctx.measureText(txt).width) * .5, 320)
			
			@setBrightness()


		initBoids: ->
			@boids = []
			for i in [0...@NUM_BOIDS]
				@addBoid()


		addBoid: ->
			# biased distribution
			iterations = 4
			x = 0
			y = 0
			for j in [0...iterations]
				x += random(sketch.width)
				y += random(sketch.height)
			x /= iterations
			y /= iterations

			pos = new Vec3D(x, y, 0)
			color = 'rgb(' + floor(random(255)) + ', 0, 84)'
			b = new Boid(sketch, pos, color)
			b.radius = random(2, 6)
			@boids.push(b)


		initImage: ->
			img = new Image()

			# start image with experiment number
			@img = document.createElement('canvas')
			@img.width = 380
			@img.height = 340
			@img.ctx = @img.getContext('2d')
			@img.ctx.font = "380px Monda"
			@img.ctx.fillStyle = '#fff'
			@img.ctx.fillText('5', (@img.width - @img.ctx.measureText('5').width) * .5, 320)

			@setBrightness()


		initGUI: ->
			gui = new dat.GUI()
			gui.add(@, 'cohesion')
			# gui.add(@, 'drawImg')
			gui.add(@, 'drawLines').listen()
			gui.add(@, 'numBoids').min(50).max(300).step(1)


		setBrightness: ->
			# store brightness values in an array
			data = @img.ctx.getImageData(0, 0, @img.width, @img.height).data
			size = @img.width * @img.height
			i = 0

			@brightness = []
			for i in [0...size]
				# store only red value, since img is b&w
				r = data[4 * i]
				@brightness.push(r)

			# console.log data
			# console.log @brightness
			# console.log @getBrightness(0, 1)

		getBrightness: (x, y) ->
			@brightness[floor(y) * @img.width + floor(x)]


do init