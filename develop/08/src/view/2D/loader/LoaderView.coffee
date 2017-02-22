class LoaderView

	el 						: null


	constructor: ->
		@el = document.getElementById('loaderUI')

		window.addEventListener(AppAudio.EVENT_AUDIO_ENDED, @onAudioEnded)
		window.addEventListener(AppAudio.EVENT_AUDIO_RESTARTED, @onAudioRestarted)


	onLoadProgress: (e) ->
		console.log('onLoadProgress')
		percent = round((e.loaded / e.total) * 100)
		@el.innerHTML = 'loading audio... ' + percent


	onLoadComplete: (e) ->
		TweenMax.to(@el, 0.3, { alpha:0, onComplete: =>
			@el.innerHTML = 'decoding audio... '
			TweenMax.to(@el, 0.3, { autoAlpha:1 })
		})
		

	onDecodeComplete: () ->
		TweenMax.to(@el, 0.3, { autoAlpha:0 })


	onError: (e) ->
		@el.innerHTML = 'smells like an error'


	onAudioEnded: (e) =>
		@el.innerHTML = '<a href="http://www.mandragoratango.com/" target="_blank">Mandr&aacute;gora Tango - Espiritu Adolescente</a>'
		TweenMax.to(@el, 0.3, { autoAlpha:1 })


	onAudioRestarted: (e) =>
		TweenMax.to(@el, 0.3, { autoAlpha:0 })

