#<< data/*
#<< utils/*
#<< model/*
#<< collection/*
#<< view/*

window.app = 
	view 			: null
	lines 			: null
	stations		: null

	init: ->
		if (!Detector.webgl) 
			Detector.addGetWebGLMessage()
			return
			
		app.initLines()
		app.initStations()


	# Load lines data
	initLines: ->
		app.lines = new LineCollection()
		app.lines.url = AppData.GET_LINES
		app.lines.fetch
			success: 	(collection, response) ->
				console.log 'app.lines.fetch success'#, collection, response
				app.initWithData()
			error:		(collection, response) =>
				console.log 'app.lines.fetch error'#, collection, response


	# Load stations data
	initStations: ->
		app.stations = new StationCollection()
		app.stations.url = AppData.GET_STATIONS
		app.stations.fetch
			success: 	(collection, response) ->
				console.log 'app.stations.fetch success'#, collection, response
				app.initWithData()
			error:		(collection, response) =>
				console.log 'app.stations.fetch error'#, collection, response


	# Proceed once lines and stations are loaded
	initWithData: ->
		if !app.lines.length then return
		if !app.stations.length then return

		app.initPredictionSummary()
		app.initView()


	# Load TFL Prediction Summary
	initPredictionSummary: ->
		app.lines.each (model, index, list) ->
			# if model.get('code') == 'H'
			if model.get('code') != 'X'
				model.once('loaded', app.onPredictionSummaryLoaded)
				model.getPredictionSummary()


	# Start main app view
	initView: ->
		app.view = new AppView()
		app.view.init()


	# Start trains on each line when the Prediction Summary is available.
	# Start clock.
	onPredictionSummaryLoaded: (code) ->
		for line in app.view.lines
			if (line.model.get('code') == code)
				line.initTrains()

		if (code == 'B') then app.view.ui.initClock()
		if (code == 'C') then app.view.show(1)

do app.init