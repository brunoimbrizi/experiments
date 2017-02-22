#<< audio/*
#<< utils/*
#<< view/*

window.app = 
	view 			: null
	audio			: null

	init: ->
		app.initAudio()
		app.initView()


	initAudio: ->
		app.audio = new AppAudio()
		app.audio.init()


	# Start main app view
	initView: ->
		app.view = new AppView()
		app.view.init()


do app.init