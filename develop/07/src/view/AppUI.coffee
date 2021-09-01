class AppUI

	view 					: null

	guiData					: null

	labelCanvas				: null
	label 					: null

	clock					: null
	clockCount				: null
	clockTimeout			: null


	constructor: ->
		@view = app.view

		@initGUI()
		@initLabel()


	initLabel: ->
		@labelCanvas = document.getElementById('canvasLabel')
		@labelCanvas.width = @view.sketch.width
		@labelCanvas.height = @view.sketch.height
		ctx = @labelCanvas.getContext('2d')

		@label = new LabelView(ctx)


	initClock: ->
		if (@clock) then return
		@clock = document.getElementById('clock')
		@clockCount = 0

		@updateClock()


	initGUI: ->
		gui = new dat.GUI()
		@guiData = new GUIData()

		# lines
		f1 = gui.addFolder('Lines')
		f1.open()	
		f1.add(@guiData, 'Bakerloo')
		f1.add(@guiData, 'Central')
		# f1.add(@guiData, 'Circle')
		f1.add(@guiData, 'District')
		f1.add(@guiData, 'Hammersmith')
		f1.add(@guiData, 'Jubilee')
		f1.add(@guiData, 'Metropolitan')
		f1.add(@guiData, 'Northern')
		f1.add(@guiData, 'Piccadilly')
		f1.add(@guiData, 'Victoria')
		# f1.add(@guiData, 'Waterloo')

		# add change listener and pass the controller
		# call onLineChange to set initial values
		that = @
		for controller in f1.__controllers
			controller.onChange(-> that.onLineChange(@))
			@onLineChange(controller)

		# trains
		f2 = gui.addFolder('Trains')
		# f2.open()
		@guiData.restart = @onRestartClick
		f2.add(@guiData, 'speed', 1, 50).onFinishChange(-> that.onSpeedChange())
		f2.add(@guiData, 'restart')

		###
		# controls
		f3 = gui.addFolder('Controls')
		f3.open()
		f3.add(@guiData, 'separate').onFinishChange(-> that.onSeparateChange())
		###

		# sound
		f4 = gui.addFolder('Sound')
		f4.add(@guiData, 'mute').onChange(-> that.onMuteChange())


	updateClock: =>
		date = new Date(@view.lines[0].model.get('date').getTime())
		date.setMinutes(date.getMinutes() + @clockCount)
		@clock.innerHTML = StringUtils.addLeadingZero(date.getHours()) + ':' + StringUtils.addLeadingZero(date.getMinutes())
		@clockCount++
		clearTimeout(@clockTimeout)
		if (@clockCount > 30) then return
		@clockTimeout = setTimeout(@updateClock, 60000 / @guiData.speed)


	toggleLabel: (selected) ->
		@view.three.selectedMatrix = new THREE.Matrix4().copy(selected.matrixWorld)
		@view.three.selectedOffset = 0
		if (@label.showed && @label.label == selected.name.toUpperCase() && @label.lineIndex == selected.lineIndex) then @label.hide(false)
		else @label.show(selected.code, selected.name, 'rgb(' + selected.color + ')', selected.lineIndex)


	# ---------------------------------------------------------------------------------------------
	# PUBLIC
	# ---------------------------------------------------------------------------------------------

	update: ->


	draw: ->
		@label.ctx.clearRect(0, 0, @view.sketch.width, @view.sketch.height)
		@label.draw()


	resize: ->
		@labelCanvas.width = @view.sketch.width
		@labelCanvas.height = @view.sketch.height


	keyup: (e) ->
		if (!@label.showed) then return
		if (e.keyCode != 39 && e.keyCode != 37) then return

		line = @view.lines[@label.lineIndex]
		branchIndex = line.getFirstBranchIndex(@label.code)
		stationIndex = line.getStationIndexInBranch(@label.code, branchIndex)
		branch = line.branches[branchIndex]
		# sprite = line.getSprite(@label.code)
		# console.log(branchIndex, stationIndex, sprite)

		# right
		if (e.keyCode == 39)
			if (stationIndex < branch.length - 1)
				nextCode = branch[stationIndex + 1]
				nextSprite = line.getSprite(nextCode)
				@toggleLabel(nextSprite)

		# left
		else if (e.keyCode == 37)
			if (stationIndex > 0)
				nextCode = branch[stationIndex - 1]
				nextSprite = line.getSprite(nextCode)
				@toggleLabel(nextSprite)


	# ---------------------------------------------------------------------------------------------
	# EVENT HANDLERS
	# ---------------------------------------------------------------------------------------------

	onLineChange: (controller) ->
		# find line
		for line in @view.lines
			if (line.model.get('code') == controller.property.substring(0, 1)) then break

		# enable or disable
		enabled = (controller.object[controller.property])
		if (enabled && !line.enabled) then line.enable()
		else if (!enabled && line.enabled) then line.disable()

		# hide label if line was disabled
		if (@label && @label.lineIndex != null)
			if(!@view.lines[@label.lineIndex].enabled) then @label.hide()


	onSpeedChange: ->
		for line in @view.lines
			if (line && line.timelines)
				for timeline in line.timelines
					timeline.timeScale(@guiData.speed)
		@clockCount--
		@updateClock()


	onRestartClick: =>
		for line in @view.lines
			if (line && line.timelines)
				for timeline in line.timelines
					timeline.restart()
		@clockCount = 0
		@updateClock()


	onSeparateChange: =>
		# app.stations.each (model, index, list) =>
			# if (model.get('position')) then model.get('position').z = 0

		iniOffset = 0

		# separate stations and offset label if necessary
		if (@guiData.separate)
			for line in @view.lines
				if (@selectedOffset && @label.showed && @label.lineIndex == line.index) then iniOffset = -@selectedOffset
				TweenLite.to(line.container.position, 1, { z: 200 - 50 * line.index, ease:Quart.easeInOut, onUpdateParams:[line], onUpdate: (line) =>
					if (@label.showed && @label.lineIndex == line.index)
						@selectedOffset = line.container.position.z - iniOffset
				} )
		# re-join stations and offset label if necessary
		else
			for line in @view.lines
				if (!@selectedOffset && @label.showed && @label.lineIndex == line.index) then iniOffset = line.container.position.z
				TweenLite.to(line.container.position, 1, { z: 0, ease:Quart.easeInOut, onUpdateParams:[line], onUpdate: (line) =>
					if (@label && @label.lineIndex == line.index)
						@selectedOffset = line.container.position.z - iniOffset
				} )


	onMuteChange: =>
		@view.audio.muted = @guiData.mute