#<< audio/*
#<< timeline/*
#<< view/*

window.app = 
	view 			: null
	audio			: null
	timeline 		: null


	init: ->
		if (!Detector.webgl) 
			Detector.addGetWebGLMessage()
			return
			
		app.initAudio()
		app.initView()
		app.initTimeline()

		app.audio.init()
		app.view.init()
		# app.timeline.init()


	initAudio: ->
		app.audio = new AppAudio()


	initView: ->
		app.view = new AppView()
		

	initTimeline: ->
		app.timeline = new AppTimeline()


do app.init