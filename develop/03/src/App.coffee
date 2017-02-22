init = ->
	sketch = Sketch.create

		points			: []
		constraints		: []
		fixedPoints		: []
		drag			: null

		ROWS			: 15
		COLS			: 24

		LENGTH 			: 15


		setup: ->
			ix = floor((sketch.width - @COLS * @LENGTH) * .5)
			iy = floor((sketch.height - @ROWS * @LENGTH) * .5)

			for i in [0...@ROWS * @COLS]
				p = @createPoint(ix + (i % @COLS) * @LENGTH, iy + floor(i / @COLS) * @LENGTH)
				###
				if (floor(i / @COLS) == 0)
					# fix 3 points
					# if (i % (@COLS * .5) == 0 or i == @COLS - 1)
					# fix 4 points
					if (i % floor(@COLS * .34) == 0 or i == @COLS - 1)
						p.setFixed(true)
						@fixedPoints.push(p)
				###

			# horizontal constraints
			for i in [0...@points.length]
				if (i % @COLS > 0) then @createConstraint(@points[i], @points[i - 1], @LENGTH)

			# vertical constraints
			for i in [0...@points.length]
				if (i >= @COLS) then @createConstraint(@points[i], @points[i - @COLS], @LENGTH)

			@setFixedPoints()


		update: ->
			for p in @points
				vx = (p.x - p.ox) * .9
				vy = (p.y - p.oy) + .4
				p.ox = p.x - vx
				p.oy = p.y - vy

			if (@drag)
				@drag.x = sketch.mouse.x
				@drag.y = sketch.mouse.y

			@updatePoints()

			for i in [0...3]
				@updateConstraints()

			# check if dropped out of screen
			if (!@fixedPoints.length)
				p0 = @points[0]
				pN = @points[@points.length - 1]
				if (p0.y > sketch.height + 400 and pN.y > sketch.height + 400)
					@reset()


		draw: ->
			sketch.fillStyle = '#ffffff'
			sketch.strokeStyle = '#999999'

			@drawPoints()
			@drawConstraints()

			# sketch.stroke()
			sketch.fill()


		reset: ->
			ix = floor((sketch.width - @COLS * @LENGTH) * .5)
			iy = floor((sketch.height - @ROWS * @LENGTH) * .5)
			i = 0

			for p in @points
				p.x = ix + (i % @COLS) * @LENGTH
				p.y = iy + floor(i / @COLS) * @LENGTH
				p.setVx(0)
				p.setVy(0)
				i++

			@setFixedPoints()


		setFixedPoints: ->
			# set fixed points
			for i in [0...@points.length]
				p = @points[i]
				if (i == 0)
					p.setFixed(true)
					@fixedPoints.push(p)
				else if (i == floor(@COLS * .5))
					p.y -= 30
					p.setFixed(true)
					@fixedPoints.push(p)
				else if (i == @COLS - 1)
					p.setFixed(true)
					@fixedPoints.push(p)
				###
				else if (floor(i / @COLS) == @ROWS - 1 and i % @COLS == @COLS - 1)
					p.setFixed(true)
					p.x += 200
					@fixedPoints.push(p)
				###


		mousedown: ->
			min = 100000000
			closest = null

			for p in @points
				dx = p.x - sketch.mouse.x
				dy = p.y - sketch.mouse.y
				dd = sqrt(dx * dx + dy * dy)
				if (dd < min)
					min = dd
					closest = p

			@drag = closest


		mouseup: ->
			@drag = null


		keydown: ->
			if (sketch.keys.F and @drag)
				@drag.setFixed(true)
				@fixedPoints.push(@drag)
				@drag = null

			if (sketch.keys.D and @drag)
				@drag.setFixed(false)
				for i in [0...@fixedPoints.length]
					if (@fixedPoints[i] == @drag) then @fixedPoints.splice(i, 1)
				@drag = null


		createPoint: (x, y) ->
			p = new VerletPoint(x, y)
			@points.push(p)
			p


		createConstraint: (pA, pB, length = -1) ->
			c = new VerletConstraint(pA, pB, length)
			@constraints.push(c)
			c


		updatePoints: ->
			for p in @points
				p.update()


		updateConstraints: ->
			for c in @constraints
				c.update()


		drawPoints: ->
			# for p in @points
			for i in [0...@points.length]
				p = @points[i]
				p.draw(sketch)


		drawConstraints: ->
			# for c in @constraints
			for i in [0...@constraints.length]
				c = @constraints[i]
				
				sketch.beginPath()
				c.draw(sketch)
				sketch.stroke()


do init