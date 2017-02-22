#<< view/*

window.app = 
	view 			: null


	init: ->
		app.initView()
		app.view.init()

		return null


	initView: ->
		app.view = new AppView()

		return null


	getParam: (name) ->
		name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
		regexS = "[\\?&]" + name + "=([^&#]*)"
		regex = new RegExp(regexS)
		results = regex.exec(window.location.search)
		if !results then return ''
		return decodeURIComponent(results[1].replace(/\+/g, " "))


window.onload = ->
	if (window.FileReader)
		cancel = (e) ->
			if (e.preventDefault) then e.preventDefault()
			return false

		drop = (e) ->
			if (e.preventDefault) then e.preventDefault()

			files = e.dataTransfer.files
			for i in [0...files.length]
				file = files[i]
				reader = new FileReader()

				reader.onloadend = (e) ->
					app.view.image.src = e.target.result

				reader.readAsDataURL(file)

			return false

		container = document.getElementById('container')
		container.ondragover = cancel
		container.ondragenter = cancel
		container.ondrop = drop


do app.init