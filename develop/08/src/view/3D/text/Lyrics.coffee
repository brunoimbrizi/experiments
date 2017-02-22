class Lyrics

	hello 					: null
	howlow 					: null

	wordHello 				: null
	wordHowLow 				: null

	showed 					: null


	constructor: ->
		@initHello()
		@initHowLow()


	setState: (state = 0) ->
		state = parseInt(state)

		switch (state)
			# SHOW HELLO
			when 0
				for letter in @wordHello
					letter.show()

				@showed = true
				@hello.scale = new THREE.Vector3(0.01, 0.01, 0.01)
				TweenLite.to(@hello.scale, 2.0, { x:0.25, y:0.25, z:0.25, ease:Quart.easeInOut })

				_gaq.push(['_trackEvent', 'state', 'show-hello'])

			# SHOW HOW LOW
			when 1
				for letter in @wordHowLow
					letter.show()

				@howlow.scale = new THREE.Vector3(2, 2, 2)
				@howlow.position.y = -150
				TweenLite.to(@howlow.position, 4.0, { y:10, ease:Quart.easeInOut })

			# HIDE HELLO
			when 2
				TweenLite.to(@hello.scale, 5.0, { x:0.01, y:0.01, z:0.01, ease:Quart.easeIn, onComplete: =>
					# for letter in @wordHello
						# letter.hide()
					for letter in @wordHello
						letter.dispose()
					@hello.parent.remove(@hello)
				})

			# PUSH HOW LOW CLOSER TO CENTER-Y
			when 3
				TweenLite.to(@howlow.position, 4.0, { y:15, ease:Quart.easeInOut })


			# HIDE ROW BY ROW
			when 4
				for letter in @wordHowLow
					for i in [0...letter.rows.length]
						row = letter.rows[i]
						delay = random()
						for bar in row
							TweenLite.to(bar.scale, 0.01, { y:0, delay:delay })

			# DISPOSE
			when 5
				for letter in @wordHowLow
						letter.dispose()
					@howlow.parent.remove(@howlow)
					@showed = false


	show: ->
		for letter in @wordHello
			letter.show()

		for letter in @wordHowLow
			letter.show()

		@hello.scale = new THREE.Vector3(0.01, 0.01, 0.01)
		TweenLite.to(@hello.scale, 2.0, { x:0.25, y:0.25, z:0.25, ease:Quart.easeInOut })

		@howlow.scale = new THREE.Vector3(2, 2, 2)
		@howlow.position.y = -150
		TweenLite.to(@howlow.position, 6.5, { y:10, delay:2.0, ease:Quart.easeInOut })


	hide: ->
		for letter in @wordHello
			letter.hide()


	restart: ->
		@showed = false
		@initHello()
		@initHowLow()


	initHello: ->
		@hello = new THREE.Object3D()
		@hello.rotation.x = HALF_PI
		@hello.rotation.z = -HALF_PI

		@wordHello = [new LetterH(), new LetterE(), new LetterL(), new LetterL(), new LetterO()]
		spacing = [2, 2, 2, 2, 1]

		@createWord(@hello, @wordHello, spacing)

		# start hidden
		for letter in @wordHello
			letter.hide()


	initHowLow: ->
		@howlow = new THREE.Object3D()
		@howlow.rotation.x = HALF_PI
		@howlow.rotation.z = -HALF_PI
		@howlow.position.z = 2

		@wordHowLow = [new LetterH(), new LetterO(), new LetterW(), new LetterL(), new LetterO(), new LetterW()]
		spacing = [2, 2, 1, 8, 1, 1]

		@createWord(@howlow, @wordHowLow, spacing)

		# start hidden
		for letter in @wordHowLow
			letter.hide()


	createWord: (container, word, spacing) ->
		wordWidth = 0

		for i in [0...word.length]
			letter = word[i]
			wordWidth += letter.width + spacing[i]
			container.add(letter.container)

		for i in [0...word.length]
			letter = word[i]
			if (!i) then letter.container.position.x = wordWidth * -0.5 + letter.width * 0.5
			else letter.container.position.x = word[i - 1].container.position.x + word[i - 1].width * 0.5 + letter.width * 0.5 + spacing[i]


	update: (values) ->
		if (!@showed) then return

		for letter in @wordHello
			letter.update(values)

		for letter in @wordHowLow
			letter.update(values)

		return