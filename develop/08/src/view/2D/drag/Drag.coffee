class Drag

	mesh				: null


	constructor: ->
		geometry = new THREE.SphereGeometry(2, 16, 8)
		material = new THREE.MeshLambertMaterial({ color:0x0000ff })
		@mesh = new THREE.Mesh(geometry, material)