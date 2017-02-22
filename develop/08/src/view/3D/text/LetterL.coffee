class LetterL extends Letter


	initLetter: ->
		@width = 9.6
		@height = 16

		hw = @width * 0.5
		hh = @height * 0.5

		sw = 3.6
		offsetX = @width - sw
		offsetY = @height / 10

		material = new THREE.MeshPhongMaterial({ color:0xffffff, emissive:0x222222, ambient:0xffffff, shininess:100 })

		for i in [0...10]
			if (i < 8)
				geometry = new THREE.CubeGeometry(sw, @thickness, @depth)
			else
				geometry = new THREE.CubeGeometry(@width, @thickness, @depth)

			mesh = new THREE.Mesh(geometry, material)
			mesh.position.y = i * -offsetY
			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y += hh - geometry.height

			@container.add(mesh)
			@bars.push(mesh)


		# rows
		for i in [0...@bars.length]
			@rows[i] = [@bars[i]]