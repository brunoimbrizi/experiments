class AppAudio

	ctx 					: null
	paused					: null

	startedAt				: null
	pausedAt				: null

	sourceNode				: null
	analyserNode			: null
	buffer 					: null

	values					: null

	FFT_SIZE				: 2048
	BINS					: 256


	init: ->
		@ctx = new webkitAudioContext()

		@values = []

		@analyserNode = @ctx.createAnalyser()
		@analyserNode.smoothingTimeConstant = 0.9
		@analyserNode.fftSize = @FFT_SIZE
		@analyserNode.connect(@ctx.destination)

		@load('sound/Sugar-and-The-Hi-Lows-Jingle-Bells.mp3')
		# @load('sound/Michael-Jackson-The-Way-You-Make-Me-Feel.mp3')
		


	update: ->
		freqData = new Uint8Array(@analyserNode.frequencyBinCount)
		@analyserNode.getByteFrequencyData(freqData)
		length = freqData.length

		bin = Math.ceil(length / @BINS)
		for i in [0...@BINS]
			sum = 0
			for j in [0...bin]
				sum += freqData[(i * bin) + j]

			# Calculate the average frequency of the samples in the bin
			average = sum / bin

			# Divide by 256 to normalize
			@values[i] = average / 256

		
	load: (url) ->
		request = new XMLHttpRequest()
		request.open('GET', url, true)
		request.responseType = 'arraybuffer'
		request.onload = =>
			@ctx.decodeAudioData(request.response, @onBufferLoad, @onBufferError)
		request.send()


	play: ->
		@sourceNode = @ctx.createBufferSource()
		@sourceNode.connect(@analyserNode)
		@sourceNode.buffer = @buffer
		@paused = false

		if (@pausedAt)
			@startedAt = Date.now() - @pausedAt
			@sourceNode.start(0, @pausedAt / 1000)
		else
			@startedAt = Date.now()
			@sourceNode.start(0)


	stop: ->
		@sourceNode.stop(0)
		@pausedAt = Date.now() - @startedAt
		@paused = true


	onBufferLoad: (@buffer) =>
		app.view.ui.onAudioLoaded()
		@play()


	onBufferError: (e) ->
		console.log('AppAudio.onBufferError', e)