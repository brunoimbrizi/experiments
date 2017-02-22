class LetterH extends Letter


	initLetter: ->
		@width = 13.8
		@height = 16

		hw = @width * 0.5
		hh = @height * 0.5

		sw = 3.6
		offsetX = @width - sw
		offsetY = @height / 10

		material = new THREE.MeshPhongMaterial({ color:0xffffff, emissive:0x222222, ambient:0xffffff, shininess:100 })

		# verticals
		for i in [0...16]
			geometry = new THREE.CubeGeometry(sw, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)

			if (i < 4)
				mesh.position.y = i * -offsetY
			else if (i < 8)
				mesh.position.y = i * -offsetY - offsetY * 2
			else if (i < 12)
				mesh.position.x = offsetX
				mesh.position.y = (i - 8) * -offsetY
			else
				mesh.position.x = offsetX
				mesh.position.y = (i - 8) * -offsetY - offsetY * 2

			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y += hh - geometry.height

			@container.add(mesh)
			@bars.push(mesh)


		# horizontals
		for i in [0...2]
			geometry = new THREE.CubeGeometry(@width, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)

			mesh.position.y = -offsetY * (4 + i)
			mesh.position.y += hh - geometry.height

			@container.add(mesh)
			@bars.push(mesh)


		# rows
		@rows[0] = [@bars[0], @bars[8]]
		@rows[1] = [@bars[1], @bars[9]]
		@rows[2] = [@bars[2], @bars[10]]
		@rows[3] = [@bars[3], @bars[11]]
		@rows[4] = [@bars[16]]
		@rows[5] = [@bars[17]]
		@rows[6] = [@bars[4], @bars[12]]
		@rows[7] = [@bars[5], @bars[13]]
		@rows[8] = [@bars[6], @bars[14]]
		@rows[9] = [@bars[7], @bars[15]]