class PlaneMesh

	mesh 					: null
	geometry				: null
	material				: null

	w						: null
	h						: null
	segmentsW				: null
	segmentsH				: null 
	hseg 					: null				

	constructor: ->
		@w = 10
		@h = 100
		@segmentsW = 1
		@segmentsH = 5
		@hseg = @h / @segmentsH

		@geometry = new THREE.PlaneGeometry(@w, @h, @segmentsW, @segmentsH)
		@material = new THREE.MeshBasicMaterial( { color:0x444444, wireframe:true } )
		@mesh = new THREE.Mesh(@geometry, @material)


	update: (value = 1) ->
		@geometry.verticesNeedUpdate = true

		hvalue = value * @segmentsH
		vertices = @geometry.vertices
		length = vertices.length

		for i in [0...length]
			v = vertices[i]
			seg = floor(i / (@segmentsW + 1))
			y = min(seg, hvalue) * @hseg
			v.y = (@h * 0.5) - y

		return null