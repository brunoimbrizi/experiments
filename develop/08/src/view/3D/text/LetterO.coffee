class LetterO extends Letter


	initLetter: ->
		@width = 13.8
		@height = 16

		hw = @width * 0.5
		hh = @height * 0.5

		sw = 3.6
		w1 = @width - sw * 2
		w2 = @width - sw
		offsetX = @width - sw
		offsetY = @height / 10

		material = new THREE.MeshPhongMaterial({ color:0xffffff, emissive:0x222222, ambient:0xffffff, shininess:100 })

		# horizontals top
		geometry = new THREE.CubeGeometry(w1, @thickness, @depth)
		mesh = new THREE.Mesh(geometry, material)
		mesh.position.y += hh - geometry.height
		@container.add(mesh)
		@bars.push(mesh)

		geometry = new THREE.CubeGeometry(w2, @thickness, @depth)
		mesh = new THREE.Mesh(geometry, material)
		mesh.position.y -= offsetY
		mesh.position.y += hh - geometry.height
		@container.add(mesh)
		@bars.push(mesh)


		# verticals
		for i in [0...12]
			geometry = new THREE.CubeGeometry(sw, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)

			if (i < 6)
				mesh.position.y = i * -offsetY
			else
				mesh.position.x = offsetX
				mesh.position.y = (i - 6) * -offsetY

			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y -= offsetY * 2
			mesh.position.y += hh - geometry.height

			@container.add(mesh)
			@bars.push(mesh)


		# horizontals bottom
		geometry = new THREE.CubeGeometry(w2, @thickness, @depth)
		mesh = new THREE.Mesh(geometry, material)
		mesh.position.y -= offsetY * 8
		mesh.position.y += hh - geometry.height
		@container.add(mesh)
		@bars.push(mesh)

		geometry = new THREE.CubeGeometry(w1, @thickness, @depth)
		mesh = new THREE.Mesh(geometry, material)
		mesh.position.y -= offsetY * 9
		mesh.position.y += hh - geometry.height
		@container.add(mesh)
		@bars.push(mesh)

		
		# rows
		@rows[0] = [@bars[0]]
		@rows[1] = [@bars[1]]
		@rows[2] = [@bars[2], @bars[8]]
		@rows[3] = [@bars[3], @bars[9]]
		@rows[4] = [@bars[4], @bars[10]]
		@rows[5] = [@bars[5], @bars[11]]
		@rows[6] = [@bars[6], @bars[12]]
		@rows[7] = [@bars[7], @bars[13]]
		@rows[8] = [@bars[14]]
		@rows[9] = [@bars[15]]