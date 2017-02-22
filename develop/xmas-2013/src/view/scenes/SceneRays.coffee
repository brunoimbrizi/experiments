class SceneRays extends AbstractScene


	constructor: (@ctx, @index) ->
		super

		@angle = 0
		@osc = 0
		@slice = TWO_PI / @reindeer.anchors.length

		@gradient = @ctx.createLinearGradient(0, 0, 10, @ctx.height)
		@gradient.addColorStop('0', 'rgba(0, 0, 255, 0.5)')
		@gradient.addColorStop('0.80', 'rgba(255, 0, 255, 0.5)')


	draw: ->
		hw = @ctx.width * .5
		hh = @ctx.height * .5
		scale = 1

		@ctx.globalCompositeOperation = 'lighter'


		if (app.view.ui.drawLines)

			# left (reindeer)
			@ctx.beginPath()
			# @ctx.strokeStyle = 'rgba(' + Math.floor(random(255)) + ', 0, 255, 0.5)'
			@ctx.strokeStyle = @gradient
			
			b = @ctx.height + @ctx.height * .25
			c = (-@ctx.height * .25 - b)
			d = 41
			for i in [0..41]
				t = i
				a = @reindeer.anchors[i]
				sx = @ctx.width

				# Quart.easeInOut
				# t /= d/2
				# if (t < 1)
					# sy = c/2*t*t*t*t + b
				# else
					# t -= 2
					# sy = -c/2 * (t*t*t*t - 2) + b

				# Linear
				sy = c * t / d + b

				# if (!(i % 2)) then @ctx.lineTo(sx, sy)
				@ctx.moveTo(sx, sy)
				@ctx.lineTo(a.pos.x * scale + hw, a.pos.y * scale + hh)
				# if (i % 2) then @ctx.lineTo(sx, sy)

			@ctx.strokeStyle = @gradient
			@ctx.lineWidth = 1
			@ctx.stroke()
			@ctx.closePath()
			##


			##
			# right (reindeer)
			@ctx.beginPath()
			@ctx.strokeStyle = 'rgba(' + Math.floor(random(255)) + ', 0, 255, 0.5)'

			b = -hh
			c = (@ctx.height + @ctx.height * .3 - b)
			d = 35
			for i in [75..110]
				t = (i - 75)
				a = @reindeer.anchors[i]
				sx = 0

				# Quart.easeInOut
				# t /= d/2
				# if (t < 1)
					# sy = c/2*t*t*t*t + b
				# else
					# t -= 2
					# sy = -c/2 * (t*t*t*t - 2) + b

				# Linear
				sy = c * t / d + b

				# if (i % 2) then @ctx.lineTo(sx, sy)
				@ctx.moveTo(sx, sy)
				@ctx.lineTo(a.pos.x * scale + hw, a.pos.y * scale + hh)
				# if (!(i % 2)) then @ctx.lineTo(sx, sy)

			@ctx.lineWidth = 1
			@ctx.stroke()
			@ctx.closePath()



			##
			# right leg and horn
			@ctx.beginPath()
			@ctx.strokeStyle = 'rgba(' + Math.floor(random(255)) + ', 0, 255, 0.7)'

			b = hh
			c = (@ctx.height - b)
			d = 12
			for i in [0..d]
				t = i
				j = 127 - i
				a = @reindeer.anchors[j]
				sx = @ctx.width

				# Quart.easeInOut
				# t /= d/2
				# if (t < 1)
					# sy = c/2*t*t*t*t + b
				# else
					# t -= 2
					# sy = -c/2 * (t*t*t*t - 2) + b

				# Linear
				sy = c * t / d + b

				# if (i % 2) then @ctx.lineTo(sx, sy)
				@ctx.moveTo(sx, sy)
				@ctx.lineTo(a.pos.x * scale + hw, a.pos.y * scale + hh)
				# if (!(i % 2)) then @ctx.lineTo(sx, sy)

			@ctx.lineWidth = 1
			@ctx.stroke()
			@ctx.closePath()



			##
			# opposites
			@ctx.beginPath()
			@ctx.strokeStyle = 'rgba(' + Math.floor(random(255)) + ', 0, 255, 0.6)'
			for i in [0...@reindeer.opposites.length]
				o = @reindeer.opposites[i]
				if (o == -1)
					o = @reindeer.opposites[i + 1]
					a = @reindeer.anchors[o]
					@ctx.moveTo(a.pos.x * scale + hw, a.pos.y * scale + hh)
					continue

				a = @reindeer.anchors[o]
				@ctx.lineTo(a.pos.x * scale + hw, a.pos.y * scale + hh)

			@ctx.lineWidth = 1
			@ctx.stroke()
			@ctx.closePath()
			##


		###
		# mask
		# @ctx.globalCompositeOperation = 'xor'
		@ctx.globalCompositeOperation = 'destination-in'

		@ctx.beginPath()
		@ctx.fillStyle = '#00ff00'
		for a in @reindeer.anchors
			@ctx.lineTo(a.pos.x + hw, a.pos.y + hh)
		@ctx.fill()
		@ctx.closePath()

		@ctx.globalCompositeOperation = 'source-over'
		###


	initReindeer: ->
		super

		# set extra properties
		# @reindeer.opposites = [0, 144, 1, 143, 2, 142, 3, 141, 4, 140, 4, 139, 5, 138, 6, 136, 7, 135, 8, 134, 9, 133, 10, 131, 11, 130, 12, 129, 13, 127, 14, 99, 15, 97, 16, 96, 17, 96, 18, 95, 20, 94, 21, 93, 22, 92, 24, 92, 25, 91, 26, 90, 27, 89, 28, 88, 29, 87, 30, 86, 31, 85, 32, 84, 33, 83, 34, 82, 35, 54, 36, 53, 37, 52, 38, 50, 39, 41, 42, 40, 43, 39, 49, 45, 46, 48, 47, 50, 56, 59, 58, 31, -1, 62, 85, 63, 84, 64, 82, 65, 81, 66, 80, 67, 79, 68, 78, 71, 72, 70, 77, 75, 74, 76, 69, -1, 98, 127, 99, 126, 100, 125, 101, 124, 102, 123, 103, 122, 104, 121, 105, 119, 106, 118, 107, 116, 108, 115, 109, 114, 110, 113, 111, 112]
		@reindeer.opposites = [0, 144, 1, 143, 2, 142, 3, 141, 4, 140, 4, 139, 5, 138, 6, 136, 7, 135, 8, 134, 9, 133, 10, 131, 11, 130, 12, 129, 13, 127, 14, 98, 15, 97, 16, 96, 17, -1, 96, 18, 95, 19, 94, 20, -1, 94, 21, 93, 22, 92, 24, 92, 25, 91, 26, 90, 27, 89, 28, 88, 29, 87, 30, 86, 31, 85, 32, 84, 33, 83, 34, 82, 35, 54, 36, 53, 37, 52, 38, 50, 39, 41, -1, 64, 82, 65, 81, 66, 80, 67, 79, 68, 78, 71, 72, 70, 77, 75, 74, 76, 69]
