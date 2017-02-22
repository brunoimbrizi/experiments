class TrainView

	container				: null
	train 					: null

	model					: null
	color					: null
	t 						: null


	constructor: (@container, @model, @color) ->
		@initTrain()


	initTrain: ->
		trainGeometry = new THREE.CubeGeometry(1, 3, 1)
		# trainMaterial = new THREE.MeshBasicMaterial({ color: @color, opacity: 0.8, transparent: true })
		trainMaterial = new THREE.MeshBasicMaterial({ color: @color })
		
		schedule = @model.get('schedule')
		station = schedule.at(0).get('station')

		@train = new THREE.Mesh(trainGeometry, trainMaterial)
		# @train.position = station.get('position')
		@container.add(@train)


	show: ->
		# @container.add(@train)
		@train.visible = true
		

	hide: ->
		# @container.remove(@train)
		@train.visible = false