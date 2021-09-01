requirejs ['sketch.min', 'TweenLite.min', 'easing/EasePack.min', 'dat.gui.min'], (sketch) ->
	console.log 'requirejs loaded'
	init()


init = ->
	sketch = Sketch.create

		down			: false
		pendulums		: null
		triggers		: null
		presets			: null
		currentPreset 	: null
		
		frameCount		: null
		freq 			: null
		preset 			: null
		volume 			: null
		restart			: null

		audioContext	: null
		gain			: null

		NUM_PENDULUMS	: 24
		OFFSET			: 45

		container: document.getElementById 'container'
		# autoclear: false
		# interval: 10


		setup: ->
			@frameCount = 0
			@volume = 1
			@freq = 7/60

			@initAudio()
			@initPresets()
			@initTriggers()
			@initPendulums()
			@initGUI()

			# @OFFSET = floor((sketch.width - 100) / @NUM_PENDULUMS)


		update: ->
			time = @frameCount += 1/60

			for p in @pendulums
				p.freq = @freq

				p.update(time)
				p.pos.x = floor((sketch.width - (@NUM_PENDULUMS - 1) * @OFFSET) * .5) + p.index * @OFFSET
				p.pos.y += sketch.height * .5

			for t in @triggers
				t.update()
				t.pos.x = floor((sketch.width - (@NUM_PENDULUMS - 1) * @OFFSET) * .5) + t.index * @OFFSET
				t.pos.y = sketch.height * .5

			@gain.gain.value = @volume


		draw: ->
			# draw axis
			sketch.lineWidth = 1
			sketch.moveTo(0, sketch.height * .5)
			sketch.lineTo(sketch.width, sketch.height * .5)
			sketch.strokeStyle = 'rgb(40, 40, 40)'
			sketch.stroke()


			for t in @triggers
				t.draw()

			sketch.globalCompositeOperation  = 'lighter'

			# draw lines
			sketch.lineWidth = 1

			for i in [0...@NUM_PENDULUMS]
				p = @pendulums[i]
				gray = 80
				for j in [0...5]
					if i > j
						o = @pendulums[i - (j + 1)]
						if o.direction == p.direction then gray = 120
						dy = min(Math.abs(p.pos.y - o.pos.y), 100)
						alpha = 1 - dy/100
						sketch.beginPath()
						sketch.moveTo(p.pos.x, p.pos.y)
						sketch.lineTo(o.pos.x, o.pos.y)
						sketch.strokeStyle = 'rgba(' + gray + ', ' + gray + ', ' + gray + ', ' + alpha + ')'
						sketch.stroke()

			###
			for i in [0...@NUM_PENDULUMS]
				p = @pendulums[i]
				t = @triggers[i]
				sketch.moveTo(p.pos.x, p.pos.y)
				sketch.lineTo(t.pos.x, t.pos.y)
			sketch.strokeStyle = 'rgba(50, 200, 220, 0.2)'
			sketch.stroke()
			###

			for p in @pendulums
				p.draw()


		mousedown: ->
			@down = true

			@audioContext.resume()

			for t in @triggers
				dx = sketch.mouse.x - t.pos.x
				dy = sketch.mouse.y - t.pos.y
				dd = dx * dx + dy * dy

				if (dd > Trigger.HIT_RADIUS_SQ) then continue
				t.mousedown()


		mouseup: ->
			@down = false


		mousemove: ->
			if !@triggers then return

			for t in @triggers
				dx = sketch.mouse.x - t.pos.x
				dy = sketch.mouse.y - t.pos.y
				dd = dx * dx + dy * dy

				if (dd < Trigger.HIT_RADIUS_SQ)
					t.mouseover()
				else if (t.over)
					t.mouseout()


		initAudio: ->
			AudioContext = window.AudioContext || window.webkitAudioContext;
			# if typeof(webkitAudioContext) != "function" then return
			@audioContext = new AudioContext()
			@gain = @audioContext.createGain()
			@gain.connect(@audioContext.destination)


		initPresets: ->
			@presets = []
			@presets.push(new Preset('preset 1', @presets.length, 7/60, [2,1,1,1,2,1,3,1,2,1,1,1,2,1,1,1,2,1,3,1,2,1,1,1]))
			@presets.push(new Preset('preset 2', @presets.length, 13/60, [0,0,2,0,5,3,3,3,2,2,0,2,0,0,2,0,0,0,3,3,0,0,0,0]))
			# @presets.push(new Preset(16/60, [0,0,2,0,0,3,5,3,3,2,0,2,0,0,2,0,0,0,3,3,0,0,0,0]))
			@currentPreset = @presets[0]

			# add preset passed in via url param
			param = @getParam('p')
			if param then urlPreset = @decodePreset(param)
			if (urlPreset)
				@presets.push(urlPreset)
				@currentPreset = urlPreset
				@preset = urlPreset.index


		initTriggers: ->
			@triggers = []

			for i in [0...@NUM_PENDULUMS]
				pos = new Point2D(i * @OFFSET, 0)
				type = @currentPreset.types[i]

				if i > @NUM_PENDULUMS * .5 then pitch = pow((i - @NUM_PENDULUMS)/12, 2) + 1
				else pitch = pow(i/12, 2) + 1

				t = new Trigger(sketch, @audioContext, @gain, i, pos, type, pitch)
				@triggers.push(t)


		initPendulums: ->
			@pendulums = []
			@freq = @currentPreset.freq

			for i in [0...@NUM_PENDULUMS]
				pos = new Point2D(i * @OFFSET, 0)
				# freq = (-51 + i) / 60
				
				trigger = @triggers[i]
				p = new Pendulum(sketch, i, pos, @freq, 1 * i, trigger)
				@pendulums.push(p)


		initGUI: ->
			@restart = ->
				@frameCount = 0
				@update()

			@save = ->
				# console.log @encodePreset()
				hasURL = false
				@url = 'http://www.brunoimbrizi.com/experiments/#/06?p=' + @encodePreset()
				for c in @gui.__controllers
					if c.property == 'url'
						c.setValue(@url)
						c.updateDisplay()
						hasURL = true
						break
				if !hasURL
					c = @gui.add(@, 'url')
				c.domElement.firstChild.focus()
				c.domElement.firstChild.select()

			# set preset names
			presetNames = {}
			for p in @presets
				presetNames[p.name] = p.index

			gui = new dat.GUI()
			gui.add(@, 'preset', presetNames).onChange((value) =>
				@currentPreset = @presets[value]
				@freq = @currentPreset.freq
				for i in [0...@NUM_PENDULUMS]
					t = @triggers[i]
					t.loadSound(@currentPreset.types[i])
			).name('presets')
			gui.add(@, 'freq').min(1/60).max(1.0).step(1/60).listen()
			gui.add(@, 'volume').min(0).max(1.0)
			gui.add(@, 'restart')
			gui.add(@, 'save').name('save')

			@gui = gui


		getParam: (name) ->
			name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
			regexS = "[\\?&]" + name + "=([^&#]*)"
			regex = new RegExp(regexS)
			results = regex.exec(window.location.search)
			if !results then return ''
			decodeURIComponent(results[1].replace(/\+/g, " "))


		encodePreset: ->
			str = ''
			str += @freq + ','
			for t in @triggers
				str += t.type + ','
			str = str.substr(0, str.length - 1)

			# return
			str


		decodePreset: (str) ->
			index = str.indexOf(',')

			freq = parseFloat(str.substring(0, index))
			freq = max(freq, 0.0)
			freq = min(freq, 1.0)

			types = str.substring(index + 1).split(',')

			# if types is too short, fill in with 0
			for i in [0...@NUM_PENDULUMS]
				if types[i]
					t = floor(types[i])
					t = max(t, 0)
					t = min(t, 5)
					types[i] = t
				else types[i] = 0

			# return
			new Preset('from url', @presets.length, freq, types)