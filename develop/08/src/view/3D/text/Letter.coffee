class Letter

	rows 					: null
	bars 					: null

	width 					: null
	height 					: null

	thickness 				: null
	depth 					: null

	disposed 				: null


	constructor: ->
		@container = new THREE.Object3D()
		@bars = []
		@rows = []
		@thickness = 0.6
		@depth = 0.6

		@initLetter()

		# store initial position
		for bar in @bars
			bar.userData = { pos:bar.position.clone() }


	show: ->
		for bar in @bars
			bar.visible = true

	hide: ->
		for bar in @bars
			bar.visible = false


	initLetter: ->
		# override


	update: (values) ->
		if (@disposed) then return
		
		hd = @depth * 0.5

		for i in [0...@rows.length]
			row = @rows[i]
			for bar in row
				bar.geometry.verticesNeedUpdate = true
				# bar.scale.x = values[i]
				# bar.position.x = bar.userData.pos.x - bar.geometry.width * 0.5 + bar.geometry.width * bar.scale.x * 0.5

				bar.scale.z = values[i] * 50
				bar.position.z = hd * bar.scale.z

		return


	dispose: ->
		for mesh in @container
			mesh.geometry.dispose()
			mesh.material.dispose()

		@disposed = true