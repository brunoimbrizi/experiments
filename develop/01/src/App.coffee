init = ->
	sketch = Sketch.create

		particles		: []
		colour  		: null
		composite  		: null
		mode			: 0
		body			: null
		timeline_0		: null
		timeline_1		: null
		timeline_2		: null

		NUM_MODES		: 3
		NUM_PARTICLES	: 30
		DISTANCE		: 50
		DISTANCE_SQ		: null
		GRAVITY			: 0
		WIND 			: 0
		DAMP			: 0.9
		COLOURS_0		: [ 'rgba(34, 34, 34, 0.1)', 'rgba(34, 34, 34, 0.5)' ]
		COLOURS_1		: [ 'rgba(243, 134, 48, 0.5)', 'rgba(250, 105, 0, 0.1)', 'rgba(250, 105, 0, 0.8)', 'rgba(192, 37, 37, 0.5)' ]
		COLOURS_2		: [ 'rgba(105, 195, 231, 0.5)', 'rgba(64, 147, 255, 0.1)', 'rgba(64, 147, 255, 0.7)', 'rgba(27, 60, 100, 0.5)' ]
		# COLOURS_1		: [ '#F38630', '#FA6900', '#c02525' ]
		# COLOURS_2		: [ '#69D2E7', '#4093ff', '#161c46' ]
		THICKNESS 		: 20

		SOURCE_OVER		: 'source-over'
		LIGHTER 		: 'lighter'

		container		: document.getElementById 'container'
		autoclear		: false


		setup: ->
			window.focus()

			@DISTANCE_SQ = @DISTANCE * @DISTANCE
			@colour = {}
			@colour.c = @COLOURS_0[0]
			@composite = @SOURCE_OVER
			@body = document.getElementsByTagName('body')[0]
			@initParticles()
			@initColours()
			@switchMode()


		update: ->
			p = @particles[0]
			p.x = sketch.mouse.x
			p.y = sketch.mouse.y

			# elastic ribbon ### also comment if (i == 0) bellow
			for i in [@NUM_PARTICLES - 1..0]
			# for i in [0...@NUM_PARTICLES]

				# thickness
				p = @particles[i]
				np = @particles[i + 1]
				pp = @particles[i - 1]

				if (i == 0) then pp = p
				else if (i == @NUM_PARTICLES - 1) then np = p
				
				dx = pp.x - np.x
				dy = pp.y - np.y

				p.angle = atan2(dy, dx) + HALF_PI
				p.mx = -p.thickness * cos(p.angle)
				p.my = -p.thickness * sin(p.angle)
				p.nx = p.thickness * cos(p.angle)
				p.ny = p.thickness * sin(p.angle)

				# vertebral column
				# if (i == 0) then continue

				# p.vx += @WIND
				# p.vy += @GRAVITY

				p.vx *= @DAMP
				p.vy *= @DAMP

				p.x += p.vx
				p.y += p.vy

				ox = p.x
				oy = p.y

				dx = p.x - pp.x
				dy = p.y - pp.y
				dd = dx * dx + dy * dy

				if (dd > @DISTANCE_SQ)
					a = atan2(dy, dx)

					p.x = pp.x + @DISTANCE * cos(a)
					p.y = pp.y + @DISTANCE * sin(a)

					p.vx += (p.x - ox) * .1
					p.vy += (p.y - oy) * .1


		draw: ->
			sketch.globalCompositeOperation = @composite

			sketch.beginPath()
			sketch.strokeStyle = @colour.c
			sketch.fillStyle = sketch.strokeStyle
			sketch.lineWidth = 1

			# draw particles
			for p in @particles
				sketch.arc(p.x, p.y, 2, 0, TWO_PI)
				sketch.closePath()

			# console.log sketch
			sketch.fill()
			sketch.beginPath()

			# draw vertebral column
			for i in [0...@NUM_PARTICLES]
				p = @particles[i]
				np = @particles[i + 1]
				pp = @particles[i - 1]

				if (i == 0) then pp = p
				else if (i == @NUM_PARTICLES - 1) then np = p

				mx = p.x + (np.x - p.x) * .5
				my = p.y + (np.y - p.y) * .5

				if @mode == 1
					# sketch.quadraticCurveTo(p.x, p.y, mx, my)
					# sketch.bezierCurveTo(p.x + p.mx, p.y + p.my, p.x + p.nx, p.y + p.ny, mx, my)
					sketch.bezierCurveTo(pp.x + cos(pp.angle + HALF_PI) * 10, pp.y + sin(pp.angle + HALF_PI) * 10, p.x - cos(p.angle + HALF_PI) * 10, p.y - sin(p.angle + HALF_PI) * 10, p.x, p.y)
				else if @mode == 2
					sketch.bezierCurveTo(pp.x + cos(pp.angle + HALF_PI) * 10, pp.y + sin(pp.angle + HALF_PI) * 10, p.x - cos(np.angle + HALF_PI) * 10, p.y - sin(np.angle + HALF_PI) * 10, np.x, np.y)
					# sketch.bezierCurveTo(pp.x + cos(pp.angle + HALF_PI) * 10, pp.y + sin(pp.angle + HALF_PI) * 10, np.x - cos(np.angle + HALF_PI) * 10, np.y - sin(np.angle + HALF_PI) * 10, np.x, np.y)
				else
					sketch.bezierCurveTo(p.x + p.mx, p.y + p.my, p.x + p.nx, p.y + p.ny, mx, my)
					# sketch.arc(p.x + p.mx, p.y + p.my, 2, 0, TWO_PI)
					sketch.arc(p.x + p.nx, p.y + p.ny, 2, 0, TWO_PI)

			sketch.stroke()
			

		keydown: ->
			if sketch.keys.C
				sketch.clear()

			else if sketch.keys.SPACE
				@switchMode()

		click: ->
			# @switchMode()

		touchend: ->
			touch = sketch.touches[0]
			if (touch.ox == touch.x && touch.oy == touch.y)
				@switchMode()


		switchMode: ->
			sketch.clear()

			if @mode < @NUM_MODES - 1 then @mode++
			else @mode = 0

			switch @mode
				when 1
					@timeline_0.stop()
					@timeline_1.play()
					@timeline_2.stop()
					@body.style.background = '#222'
					try(parent.document) parent.app.updateBodyClass('')
					@composite = @LIGHTER
				when 2
					@timeline_0.stop()
					@timeline_1.stop()
					@colour.c = @COLOURS_2[0]
					@timeline_2.play()
					@body.style.background = '#222'
					try(parent.document) parent.app.updateBodyClass('')
					composite = @LIGHTER
				else
					@timeline_0.play()
					@timeline_1.stop()
					@timeline_2.stop()
					@colour.c = @COLOURS_0[0]
					@body.style.background = '#FFF'
					try(parent.document) parent.app.updateBodyClass('white')
					@composite = @SOURCE_OVER


		initParticles: ->
			for i in [0...@NUM_PARTICLES]
				p =
					x			: sketch.mouse.x
					y			: sketch.mouse.y
					vx			: 0
					vy			: 0
					angle 		: 0
					thickness 	: 0
					# anchors
					mx			: 0
					my			: 0
					nx			: 0
					ny			: 0

				if (i < @NUM_PARTICLES * .5) then p.thickness = @THICKNESS * (i / @NUM_PARTICLES)
				else p.thickness = @THICKNESS * ((@NUM_PARTICLES - i) / @NUM_PARTICLES)
					
				@particles.push(p)


		initColours: ->
			@timeline_0 = new TimelineMax( {repeat:-1, paused:true} )
			for i in [0...@COLOURS_0.length]
				@timeline_0.to(@colour, 3, { colorProps:{ c:@COLOURS_0[i] } } )
			@timeline_0.to(@colour, 3, { colorProps:{ c:@COLOURS_0[0] } } )

			@timeline_1 = new TimelineMax( {repeat:-1, paused:true} )
			for i in [0...@COLOURS_1.length]
				@timeline_1.to(@colour, 3, { colorProps:{ c:@COLOURS_1[i] } } )
			@timeline_1.to(@colour, 3, { colorProps:{ c:@COLOURS_1[0] } } )

			@timeline_2 = new TimelineMax( {repeat:-1, paused:true} )
			for i in [0...@COLOURS_2.length]
				@timeline_2.to(@colour, 3, { colorProps:{ c:@COLOURS_2[i] } } )
			@timeline_2.to(@colour, 3, { colorProps:{ c:@COLOURS_2[0] } } )



do init