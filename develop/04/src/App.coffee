init = ->
	sketch = Sketch.create

		boids 			: null
		path			: null
		drags			: null

		down			: false
		drawPath 		: true
		drawAnchors 	: true
		brakeOnCurves	: false
		takeShortcuts	: false
		numBoids		: 0
		clearPath		: null

		NUM_BOIDS		: 30
		# COLOURS			: [ '#9e0b0f', '#ff0000', '#F38630', '#666', '#FA6900' ]
		# COLOURS			: [ '#606E00', '#A1BA00', '#6E3300', '#BA5700' ]
		COLOURS			: [ '#6dcff6', '#0054a6', '#0072bc', '#448ccb' ]
		# COLOURS			: [ '#BC2009', '#701406', '#BD7B09', '#704906' ]
		# COLOURS			: [ '#BC2009', '#701406' ]


		container: document.getElementById 'container'
		# autoclear: false
		# interval: 10


		setup: ->
			@drags = []
			@numBoids = @NUM_BOIDS

			window.sketch = sketch

			@initBoids()
			@initPath()
			@initGUI()


		update: ->
			if (@brakeOnCurves != @boids[0].pathBrakeOnCurves)
				for boid in @boids
					boid.pathBrakeOnCurves = !boid.pathBrakeOnCurves

			if (@takeShortcuts != @boids[0].pathTakeShortcuts)
				for boid in @boids
					boid.pathTakeShortcuts = !boid.pathTakeShortcuts

			diffBoids = @numBoids - @boids.length
			if (diffBoids > 0)
				for i in [0...diffBoids]
					pos = new Vec3D(sketch.width * .5 + random(50), sketch.height * .5 + random(-50, 50), random(-50, 50))
					color = random(@COLOURS)
					@boids.push(new RibbonBoid(sketch, pos, color))
					# @boids.push(new Boid(sketch, pos, color))
			else if (diffBoids < 0)
				diffBoids *= -1
				for i in [0...diffBoids]
					@boids.pop()

			i = 0
			for boid in @boids
				# if (i == 0) then boid.acc.addSelf(boid.seek(new Vec3D(sketch.mouse.x, sketch.mouse.y, 0)))
				# else boid.acc.addSelf(boid.pursue(@boids[i - 1]))
				# boid.acc.addSelf(boid.seek(new Vec3D(sketch.mouse.x, sketch.mouse.y, 0)))
				# boid.acc.addSelf(boid.wander().scaleSelf(0.5))
				boid.acc.addSelf(boid.separate(@boids).scaleSelf(1))
				# boid.acc.addSelf(boid.cohesion(@boids).scaleSelf(0.001))
				# boid.acc.addSelf(boid.align(@boids).scaleSelf(0.1))
				boid.acc.addSelf(boid.followPath(@path))
				boid.update()
				boid.wrap()
				i++


		draw: ->
			sketch.globalCompositeOperation  = 'lighter'

			for boid in @boids
				boid.draw()

			if @drawPath then @path.render()

			if !@drawAnchors then return
			for drag in @drags
				drag.render()


		mousedown: ->
			@down = true
			hit = false

			for drag in @drags
				dx = sketch.mouse.x - drag.pos.x
				dy = sketch.mouse.y - drag.pos.y
				dd = dx * dx + dy * dy

				if (dd > Drag.HIT_RADIUS_SQ) then continue

				if (sketch.keys.D)
					index = @drags.indexOf(drag)
					@drags.splice(index, 1)
					@path.removePoint(index)
				else
					drag.mousedown()

				hit = true
				break

			if (!hit)
				drag = new Drag(sketch, new Vec3D(sketch.mouse.x, sketch.mouse.y, 0))
				@drags.push(drag)
				@path.addPoint(drag.pos)


		mousemove: ->
			for drag in @drags
				dx = sketch.mouse.x - drag.pos.x
				dy = sketch.mouse.y - drag.pos.y
				dd = dx * dx + dy * dy

				if (dd < Drag.HIT_RADIUS_SQ)
					drag.mouseover()
				else if (drag.over)
					drag.mouseout()

				if (drag.down) then drag.mousemove()


		mouseup: ->
			@down = false
			for drag in @drags
				if (drag.down) then drag.mouseup()


		keydown: ->
			if (sketch.keys.P)
				@drawPath = !@drawPath

			if (sketch.keys.A)
				@drawAnchors = !@drawAnchors

			if (sketch.keys.B)
				@brakeOnCurves = !@brakeOnCurves

			if (sketch.keys.S)
				@takeShortcuts = !@takeShortcuts


		initBoids: ->
			@boids = []
			for i in [0...@NUM_BOIDS]
				pos = new Vec3D(sketch.width * .5 + random(50), sketch.height * .5 + random(-50, 50), random(-50, 50))
				# color = random(@COLOURS)
				color = 'rgb(20,' + floor(random(50, 255)) + ', ' + floor(random(10, 50)) + ')'
				@boids[i] = new RibbonBoid(sketch, pos, color)
				# @boids[i] = new Boid(sketch, pos, color)


		initPath: ->
			@path = new Path(sketch)
			# for i in [0..5]
				# @path.addPoint(new Vec3D(300 + 200 * i, 200 + 200 * (i % 2), 0))


		initGUI: ->
			@clearPath = ->
				while @drags.length
					@drags.pop()
				while @path.points.length
					@path.removePoint(0)

			gui = new dat.GUI()
			gui.add(@, 'drawPath').listen()
			gui.add(@, 'drawAnchors').listen()
			gui.add(@, 'brakeOnCurves').listen()
			gui.add(@, 'takeShortcuts').listen()
			gui.add(@, 'numBoids').min(1).max(60).step(1)
			gui.add(@, 'clearPath')


do init