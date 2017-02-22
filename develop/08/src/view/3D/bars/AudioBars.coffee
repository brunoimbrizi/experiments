class AudioBars

	container			: null
	bars 				: null

	updateWithAudio		: true
	animationValues 	: null


	constructor: ->
		@initContainer()
		@initBars()
		@setState(0)

		window.addEventListener(AppAudio.EVENT_AUDIO_RESTARTED, @onAudioRestarted)


	initContainer: ->
		@container = new THREE.Object3D()


	initBars: ->
		@bars = []

		for i in [0...10]
			bar = new AudioBar(i)
			@bars.push(bar)
			@container.add(bar.mesh)


	update: (values) ->
		if (!@updateWithAudio) 
			values = @animationValues

		length = @bars.length
		for i in [0...length]
			# value = if (values && values[i]) then values[i] else 1
			value = if (values && values[i]) then values[i] else 0
			bar = @bars[i]
			bar.update(value)

		return


	setState: (state = 0) ->
		length = @bars.length
		state = parseInt(state)

		# console.log('AudioBars.setState', state)

		switch (state)
			# SPHERE ONLY Y AND Z
			when 0
				for i in [0...length]
					bar = @bars[i]
					TweenLite.to(bar, 0.8, { radius:random(38, 40), thickness:1, depth:1, circ:1, ease:Quart.easeInOut })
					TweenLite.to(bar.mesh.position, 0.8, { z:0 })
					bar.constRotationZ = random(0.1)
					bar.targetRotationX = 0
					bar.targetRotationY = random(0, TWO_PI)
					bar.targetRotationZ = random(0, TWO_PI)

			# SPHERE ALL AXIS
			when 1
				for i in [0...length]
					bar = @bars[i]
					rnd = random()
					TweenLite.to(bar, 1.5, { depth:4, targetRotationX:rnd * TWO_PI, delay:0, ease:Expo.easeInOut })
					# bar.constRotationZ = 0.0
					bar.scaleZ = false

			# TARGET
			when 2
				for i in [0...length]
					bar = @bars[i]
					rnd = random(0, TWO_PI)
					TweenLite.to(bar, 2.5, { radius:5 * i + 10, thickness:4, depth:random(15), delay:(i / length) * 0.25, ease:Quart.easeInOut })
					TweenLite.to(bar, (i / length) * 0.2 + 1.5, { targetRotationX:0, targetRotationY:0, targetRotationZ:rnd, ease:Quart.easeInOut })
					TweenLite.to(bar.mesh.scale, 1.0, { z:0, onCompleteParams:[bar], onComplete: (b) ->
						b.scaleZ = true
					})
					bar.constRotationZ = 0

			# CYLINDER
			when 3
				depths = 0
				ndepth = 0
				for i in [0...length]
					bar = @bars[i]
					ndepth = random(1, 10)
					rnd = random(0, TWO_PI)
					TweenLite.to(bar, 0.8, { radius:random(30, 40), thickness:random(1, 6), depth:ndepth, circ:1, targetRotationZ:rnd, delay:(i / length) * 0.1 + 0.3, ease:Quart.easeInOut })
					bar.mesh.userData.z = depths
					depths += ndepth + 1
				for i in [0...length]
					bar = @bars[i]
					bar.mesh.userData.z -= depths * .5
					nz = bar.mesh.userData.z
					TweenLite.to(bar.mesh.position, 1.5, { z:nz, ease:Quart.easeInOut })

			# CONE FROM THE TOP
			when 4
				for i in [0...length]
					bar = @bars[i]
					TweenLite.to(bar, 5.0, { thickness:(i + 1), radius:random(30, 36) + i, ease:Quart.easeInOut })


			# HIDE CONE
			when 5
				@updateWithAudio = false
				@animationValues = []


			# SHOW STRAIGHT BARS
			when 6
				@updateWithAudio = true

				ndepth = 3.2
				for i in [0...length]
					bar = @bars[i]
					bar.radius = 30
					bar.thickness = 8.0
					bar.depth = 1.2
					bar.circ = 0

					bar.mesh.position.x = -10
					bar.mesh.position.y = bar.thickness * .5
					bar.mesh.position.z = ndepth * -i + ndepth * length * .5 + ndepth * .5
					bar.mesh.rotation.x = bar.mesh.rotation.y = bar.mesh.rotation.z = 0
					bar.targetRotationX = bar.targetRotationY = bar.targetRotationZ = 0
					bar.scaleX = bar.scaleY = bar.scaleZ = false
					bar.constRotationZ = false
					bar.mesh.scale.x = bar.mesh.scale.y = bar.mesh.scale.z = 1


			# ELONGATE STRAIGHT BARS
			when 7
				ndepth = 5
				for i in [0...length]
					bar = @bars[i]
					posZ = ndepth * -i + ndepth * length * .5 + ndepth * .5
					TweenLite.to(bar, 8.0, { thickness:3, ease:Quart.easeInOut })
					TweenLite.to(bar.mesh.position, 8.0, { z:posZ, ease:Quart.easeInOut })
					###
					bar = @bars[i]
					bar.mesh.position.x = cos((PI * 2 / 10) * i) * -45
					bar.mesh.position.y = sin((PI * 2 / 10) * i) * -45
					bar.mesh.position.z = 0
					bar.mesh.rotation.x = 0
					bar.mesh.rotation.y = 0
					bar.mesh.rotation.z = (PI * 2 / 10) * i
					bar.rotateX = bar.rotateY = bar.rotateZ = false
					###

					###
					for (var i = 0; i < 10; i++) {
					bar = app.view.three.bars.bars[i];
					bar.mesh.position.x = Math.cos((Math.PI * 2 / 10) * i) * -10;
					bar.mesh.position.y = Math.sin((Math.PI * 2 / 10) * i) * -10;
					bar.mesh.position.z = i;
					bar.mesh.rotation.x = 0;
					bar.mesh.rotation.y = 0;
					bar.mesh.rotation.z = (Math.PI * 2 / 10) * i;
					bar.targetRotationZ = bar.mesh.rotation.z;
					bar.rotateZ = true;
					bar.scaleZ = true;
					bar.thickness = 1;
					bar.circ = 1;
					bar.depth = 1;
					}
					###


			# SPHERE
			when 8
				for i in [0...length]
					bar = @bars[i]
					TweenLite.to(bar, 1.0, { radius:random(38, 40), thickness:1, depth:2, circ:1, targetRotationX:random(0, PI), targetRotationY:random(0, PI), targetRotationZ:random(0, PI), ease:Quart.easeInOut })
					TweenLite.to(bar.mesh.position, 1.0, { x:0, y:0, z:0, ease:Quart.easeInOut })
					bar.constRotationZ = random(0.05)


			# CYLYNDER
			when 9
				depths = 0
				ndepth = 0
				for i in [0...length]
					bar = @bars[i]
					ndepth = random(5, 10)
					rnd = random(0, TWO_PI)
					TweenLite.to(bar, 0.8, { radius:random(30, 40), thickness:random(2, 6), depth:ndepth, circ:1, delay:(i / length) * 0.1, ease:Quart.easeInOut })
					TweenLite.to(bar, 0.5, { targetRotationX:0, targetRotationY:0, targetRotationZ:rnd })
					TweenLite.to(bar.mesh.scale, 0.5, { z:0.5, delay:0.5, onCompleteParams:[bar], onComplete: (b) ->
						b.scaleZ = true
					})
					bar.mesh.userData.z = depths
					bar.constRotationZ = 0
					depths += ndepth + 1
				for i in [0...length]
					bar = @bars[i]
					bar.mesh.userData.z -= depths * .5
					nz = bar.mesh.userData.z
					TweenLite.to(bar.mesh.position, 1.5, { x:0, y:0, z:nz, ease:Quart.easeInOut })


	onAudioRestarted: (e) =>
		for i in [0...@bars.length]
			bar = @bars[i]
			bar.scaleX = bar.scaleY = false
			bar.scaleZ = true
			bar.rotateX = bar.rotateY = bar.rotateZ = true
			bar.constRotationZ = 0
			bar.targetRotationX = targetRotationY = targetRotationZ = null
			bar.mesh.position.x = bar.mesh.position.y = bar.mesh.position.z = 0
			bar.mesh.rotation.x = bar.mesh.rotation.y = bar.mesh.rotation.z = 0

		@setState(0)

		return