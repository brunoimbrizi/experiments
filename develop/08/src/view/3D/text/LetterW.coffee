class LetterW extends Letter


	initLetter: ->
		@width = 17.6
		@height = 16

		hw = @width * 0.5
		hh = @height * 0.5

		sw = 3.6
		offsetX = @width - sw
		offsetY = @height / 10
		nudgeX = sw / 10

		material = new THREE.MeshPhongMaterial({ color:0xffffff, emissive:0x222222, ambient:0xffffff, shininess:100 })

		# left
		for i in [0...5]
			geometry = new THREE.CubeGeometry(sw, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)

			mesh.position.y = i * -offsetY
			mesh.position.x = i * nudgeX

			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y += hh - geometry.height

			@container.add(mesh)
			@bars.push(mesh)


		# bottom center
		for i in [0...2]
			if (i == 0) then w = @width - nudgeX * 10
			else if (i == 1) then w = @width - nudgeX * 12

			geometry = new THREE.CubeGeometry(w, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)
			mesh.position.x = (@width - geometry.width) * 0.5
			mesh.position.y -= offsetY * (i + 5)
			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y += hh - geometry.height
			@container.add(mesh)
			@bars.push(mesh)


		# bottom left
		for i in [0...3]			
			if (i == 0) then w = sw + nudgeX * 4
			else if (i == 1) then w = sw + nudgeX * 2
			else if (i == 2) then w = sw

			geometry = new THREE.CubeGeometry(w, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)
			mesh.position.x = nudgeX * (i + 7)
			mesh.position.y -= offsetY * (i + 7)
			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y += hh - geometry.height
			@container.add(mesh)
			@bars.push(mesh)


		# top center
		for i in [0...3]			
			if (i == 0) then w = sw
			else if (i == 1) then w = sw + nudgeX * 2
			else if (i == 2) then w = sw + nudgeX * 4

			geometry = new THREE.CubeGeometry(w, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)
			mesh.position.x = (@width - geometry.width) * 0.5
			mesh.position.y -= offsetY * (i + 2)
			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y += hh - geometry.height
			@container.add(mesh)
			@bars.push(mesh)


		# right
		for i in [0...5]
			geometry = new THREE.CubeGeometry(sw, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)

			mesh.position.y = i * -offsetY
			mesh.position.x = (@width - geometry.width) - i * nudgeX

			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y += hh - geometry.height

			@container.add(mesh)
			@bars.push(mesh)


		# bottom right
		for i in [0...3]			
			if (i == 0) then w = sw + nudgeX * 4
			else if (i == 1) then w = sw + nudgeX * 2
			else if (i == 2) then w = sw

			geometry = new THREE.CubeGeometry(w, @thickness, @depth)
			mesh = new THREE.Mesh(geometry, material)
			mesh.position.x = @width * 0.5 + nudgeX * (i + 3)
			mesh.position.y -= offsetY * (i + 7)
			mesh.position.x -= (@width - geometry.width) * 0.5
			mesh.position.y += hh - geometry.height
			@container.add(mesh)
			@bars.push(mesh)


		# rows
		@rows[0] = [@bars[0], @bars[13]]
		@rows[1] = [@bars[1], @bars[14]]
		@rows[2] = [@bars[2], @bars[10], @bars[15]]
		@rows[3] = [@bars[3], @bars[11], @bars[16]]
		@rows[4] = [@bars[4], @bars[12], @bars[17]]
		@rows[5] = [@bars[5]]
		@rows[6] = [@bars[6]]
		@rows[7] = [@bars[7], @bars[18]]
		@rows[8] = [@bars[8], @bars[19]]
		@rows[9] = [@bars[9], @bars[20]]