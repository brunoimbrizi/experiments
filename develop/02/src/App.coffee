init = ->
	sketch = Sketch.create

		particles		: []
		mode			: 0

		NUM_MODES		: 4
		NUM_PARTICLES	: 50
		DISTANCE		: 30
		DISTANCE_SQ		: null
		GRAVITY			: 0
		WIND 			: 0
		DAMP			: 0.9
		COLOURS			: [ '#69D2E7', '#A7DBD8', '#E0E4CC', '#F38630', '#FA6900', '#FF4E50', '#F9D423' ]
		THICKNESS 		: 23

		container		: document.getElementById 'container'

		setup: ->
			window.focus()

			@DISTANCE_SQ = @DISTANCE * @DISTANCE
			@initParticles()


		update: ->
			p = @particles[0]
			p.x = sketch.mouse.x
			p.y = sketch.mouse.y

			if (!p.x and !p.y)
				p.x = sketch.width * .5
				p.y = sketch.height * .5

			# rigid
			if @mode == 1 or @mode == 3
				start = 0
				end = @NUM_PARTICLES - 1
			# elastic
			else
				start = @NUM_PARTICLES - 1
				end = 0

			for i in [start..end]
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
				if @mode == 1
					if (i == 0) then continue

				p.vx += @WIND
				p.vy += @GRAVITY

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

					if @mode == 3
						damp = .15
					else
						damp = .1
					p.vx += (p.x - ox) * damp
					p.vy += (p.y - oy) * damp


		draw: ->
			sketch.globalCompositeOperation = 'lighter'

			sketch.beginPath()
			sketch.strokeStyle = @COLOURS[floor((sketch.now * 0.0003) % @COLOURS.length)]
			# console.log sketch.millis, Date.now(), sketch.now, sketch.dt
			sketch.fillStyle = sketch.strokeStyle
			sketch.lineWidth = 1

			# draw particles
			if @mode == 0
				for p in @particles
					sketch.arc(p.x, p.y, 2, 0, TWO_PI)
					sketch.closePath()

				sketch.fill()

			###
			# draw vertebrae
			for p in @particles
				sketch.moveTo(p.x + p.mx, p.y + p.my)
				sketch.lineTo(p.x + p.nx, p.y + p.ny)

			sketch.stroke()
			###

			# draw vertebral column
			if @mode == 0 or @mode == 2
				sketch.beginPath()

				for i in [0...@NUM_PARTICLES]
					p = @particles[i]
					np = @particles[i + 1]
					pp = @particles[i - 1]

					if (i == 0) then pp = p
					else if (i == @NUM_PARTICLES - 1) then np = p

					mx = p.x + (np.x - p.x) * .5
					my = p.y + (np.y - p.y) * .5

					# sketch.quadraticCurveTo(p.x, p.y, mx, my)

					# shape 1
					# sketch.bezierCurveTo(p.x + p.mx, p.y + p.my, p.x + p.nx, p.y + p.ny, mx, my)
					# sketch.arc(p.x + p.mx, p.y + p.my, 2, 0, TWO_PI)
					# sketch.arc(p.x + p.nx, p.y + p.ny, 2, 0, TWO_PI)
					
					# shape 2
					if @mode == 2
						thickness = @THICKNESS
						tcos = thickness * cos(p.angle + HALF_PI)
						tsin = thickness * sin(p.angle + HALF_PI)
						sketch.arc(p.x + tcos, p.y + tsin, 4, 0, TWO_PI)
						sketch.arc(p.x - tcos, p.y - tsin, 4, 0, TWO_PI)

					# shape 3
					if @mode == 0
						thickness = p.thickness
						sketch.arc(p.x + thickness * cos(p.angle), p.y + thickness * sin(p.angle), 4, 0, TWO_PI)
						sketch.arc(p.x - thickness * cos(p.angle), p.y - thickness * sin(p.angle), 4, 0, TWO_PI)

				sketch.stroke()
			
			# draw outline
			if @mode == 1
				sketch.beginPath()

				mmx0 = null
				mmy0 = null

				# draw top line
				for i in [0...@NUM_PARTICLES - 1]
					p = @particles[i]
					np = @particles[i + 1]
					pp = @particles[i - 1]

					p_mx = p.x + p.mx
					p_my = p.y + p.my
					np_mx = np.x + np.mx
					np_my = np.y + np.my
					mmx = p_mx + (np_mx - p_mx) * .5
					mmy = p_my + (np_my - p_my) * .5

					if (i == 0)
						sketch.moveTo(mmx, mmy)
						mmx0 = mmx
						mmy0 = mmy
					else
						pp_mx = pp.x + pp.mx
						pp_my = pp.y + pp.my
						pmx = p_mx + (pp_mx - p_mx) * .5
						pmy = p_my + (pp_my - p_my) * .5
						# sketch.moveTo(pmx, pmy)
						# sketch.quadraticCurveTo(p_mx, p_my, mmx, mmy)
						# sketch.arc(p_mx, p_my, 2, 0, TWO_PI)
						# sketch.arc(p_mx - cos(p.angle + HALF_PI) * 10, p_my - sin(p.angle + HALF_PI) * 10, 2, 0, TWO_PI)
						sketch.bezierCurveTo(pp_mx + cos(pp.angle + HALF_PI) * 10, pp_my + sin(pp.angle + HALF_PI) * 10, np_mx - cos(np.angle + HALF_PI) * 10, np_my - sin(np.angle + HALF_PI) * 10, np_mx, np_my)
						# sketch.bezierCurveTo(p_mx + cos(p.angle + HALF_PI) * 10, p_my + sin(p.angle + HALF_PI) * 10, np_mx - cos(np.angle + HALF_PI) * 10, np_my - sin(np.angle + HALF_PI) * 10, np_mx, np_my)

				# draw bottom line
				for i in [@NUM_PARTICLES - 1...0]
					p = @particles[i]
					np = @particles[i - 1]
					pp = @particles[i + 1]

					p_nx = p.x + p.nx
					p_ny = p.y + p.ny
					np_nx = np.x + np.nx
					np_ny = np.y + np.ny
					mnx = p_nx + (np_nx - p_nx) * .5
					mny = p_ny + (np_ny - p_ny) * .5

					if (i != @NUM_PARTICLES - 1)
						pp_nx = pp.x + pp.nx
						pp_ny = pp.y + pp.ny
						pnx = p_nx + (pp_nx - p_nx) * .5
						pny = p_ny + (pp_ny - p_ny) * .5
						# sketch.moveTo(pnx, pny)
						sketch.quadraticCurveTo(p_nx, p_ny, mnx, mny)

				# draw head
				p = @particles[0]
				ax = @THICKNESS * cos(p.angle + HALF_PI)
				ay = @THICKNESS * sin(p.angle + HALF_PI)
				sketch.bezierCurveTo(p.x + p.nx - ax, p.y + p.ny - ay, p.x + p.mx - ax, p.y + p.my - ay, mmx0, mmy0)
				sketch.lineTo(mmx0, mmy0)

				sketch.stroke()
				# sketch.fill()
			
			if @mode == 3
				sketch.beginPath()

				# draw outline in a single loop
				for i in [0...@NUM_PARTICLES - 1]
					p = @particles[i]
					np = @particles[i + 1]
					pp = @particles[i - 1]

					p_mx = p.x + p.mx
					p_my = p.y + p.my
					np_mx = np.x + np.mx
					np_my = np.y + np.my
					mmx = p_mx + (np_mx - p_mx) * .5
					mmy = p_my + (np_my - p_my) * .5

					sketch.arc(mmx, mmy, 2, 0, TWO_PI)

					p_nx = p.x + p.nx
					p_ny = p.y + p.ny
					np_nx = np.x + np.nx
					np_ny = np.y + np.ny
					mnx = p_nx + (np_nx - p_nx) * .5
					mny = p_ny + (np_ny - p_ny) * .5

					if (i == 0)
						# sketch.moveTo(mmx, mmy)
						# sketch.lineTo(p_mx, p_my)
						# sketch.lineTo(p_nx, p_ny)
						# sketch.lineTo(mnx, mny)
					else
						pp_mx = pp.x + pp.mx
						pp_my = pp.y + pp.my
						pmx = p_mx + (pp_mx - p_mx) * .5
						pmy = p_my + (pp_my - p_my) * .5
						sketch.moveTo(pmx, pmy)
						sketch.quadraticCurveTo(p_mx, p_my, mmx, mmy)

						pp_nx = pp.x + pp.nx
						pp_ny = pp.y + pp.ny
						pnx = p_nx + (pp_nx - p_nx) * .5
						pny = p_ny + (pp_ny - p_ny) * .5
						sketch.moveTo(pnx, pny)
						sketch.quadraticCurveTo(p_nx, p_ny, mnx, mny)

					sketch.moveTo(mmx, mmy)
					sketch.lineTo(mnx, mny)

				sketch.stroke()
			
			
		keydown: ->
			if sketch.keys.SPACE
				@switchMode()


		click: ->
			# @switchMode()


		touchend: ->
			touch = sketch.touches[0]
			if (touch.ox == touch.x && touch.oy == touch.y)
				@switchMode()


		switchMode: ->
			if @mode < @NUM_MODES - 1 then @mode++
			else @mode = 0

			switch @mode
				when 1
					@DISTANCE = 20
					@THICKNESS = 10
					for i in [0...@NUM_PARTICLES]
						p = @particles[i]
						p.thickness = @THICKNESS * ((i - @NUM_PARTICLES) / @NUM_PARTICLES)
				when 2
					@DISTANCE = 30
					@THICKNESS = 20
					for i in [0...@NUM_PARTICLES]
						p = @particles[i]
						p.thickness = @THICKNESS * (Math.abs(i - @NUM_PARTICLES * .5) / @NUM_PARTICLES)
				when 3
					@DISTANCE = 40
					@THICKNESS = 30
					for i in [0...@NUM_PARTICLES]
						p = @particles[i]
						p.thickness = @THICKNESS * (Math.abs(i - @NUM_PARTICLES * .5) / @NUM_PARTICLES)
				else
					@DISTANCE = 30
					@THICKNESS = 20
					for i in [0...@NUM_PARTICLES]
						p = @particles[i]
						if (i < @NUM_PARTICLES * .5) then p.thickness = @THICKNESS * (i / @NUM_PARTICLES)
						else p.thickness = @THICKNESS * ((@NUM_PARTICLES - i) / @NUM_PARTICLES)

			@DISTANCE_SQ = @DISTANCE * @DISTANCE


		initParticles: ->
			for i in [0...@NUM_PARTICLES]
				p =
					x			: sketch.width * .2 + sin(i * .1) * @DISTANCE * i
					y			: sketch.height * .5 + cos(i * .1) * @DISTANCE * i
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


do init