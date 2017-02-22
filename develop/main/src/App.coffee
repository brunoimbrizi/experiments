requirejs ['jquery', 'jquery.animate-colors-min', 'jquery.easing.1.3', 'jquery.address-1.5.min'], ($) ->
	# console.log 'requirejs loaded'

$ ->

	window.app = 

		current					: null

		NUM_EXPERIMENTS			: null


		initMenu: ->
			###
			@NUM_EXPERIMENTS = $('#info').children().length

			for i in [0...app.NUM_EXPERIMENTS]
				a = app.addLeadingZero(i + 1)
				$('#menu').append '<a href="' + a + '/index.html">' + a + '</a>'
			###

			arr = ['01', '02', '03', '04', '05', '06', '07', '08', '09', 'go-with-the-flow']

			@NUM_EXPERIMENTS = arr.length

			for i in [0...app.NUM_EXPERIMENTS]
				n = app.addLeadingZero(i + 1)
				a = arr[i]
				$('#menu').append '<a href="' + a + '/index.html">' + n + '</a>'
			
			$('#menu a').bind('click', app.onMenuClick)
			$('#info').css('display', 'block')
			$('#loading').css('display', 'none')

			# $('#ui').bind('mouseover', app.onUiMouseOver)
			# $('#ui').bind('mouseout', app.onUiMouseOut)


		onUiMouseOver: (e) ->
			$('#menu').stop().animate( { backgroundColor: 'rgba(0, 0, 0, 0.95)' }, 100 )
			$('#info').stop().animate( { backgroundColor: 'rgba(0, 0, 0, 0.95)' }, 100 )


		onUiMouseOut: (e) ->
			$('#menu').stop().animate( { backgroundColor: 'rgba(0, 0, 0, 0.8)' }, 200 )
			$('#info').stop().animate( { backgroundColor: 'rgba(0, 0, 0, 0.6)' }, 200 )


		onMenuClick: (e) ->
			e.preventDefault()
			# app.navTo(e.target)
			$.address.value(e.target.innerHTML)


		navTo: (index) ->
			# index = null
			# href = $(target).attr 'href'

			index = Math.floor(index) - 1
			target = $('#menu a')[index]
			href = $(target).attr('href') + '?' + $.address.queryString()

			# set iframe src immediatelly
			if (@current == null)
				$('#content iframe').remove()
				$('<iframe/>').attr('src', href).appendTo('#content')

			# slide overlay
			else
				$('#overlay').css 'display', 'block'
				$('#overlay').css 'left', '0'
				$('#overlay').width(0)
				$('#overlay').animate {width:$(window).width()}, 800, 'easeInOutQuint', ->
					# set iframe src
					$('#content iframe').remove()
					$('<iframe/>').attr('src', href).appendTo('#content')
					$('#content iframe').load(app.onIframeLoad)

					# clear any added classes to body
					$('body').removeClass()

			# set selected
			for i in [0...$('#menu a').length]
				a = $($('#menu a')[i])
				if a.hasClass('selected')
					a.removeClass('selected')
				# if $('#menu a')[i] == target then index = i
			$(target).addClass 'selected'
			@current = index

			# set info
			for i in [0...$('#info span').length]
				$($('#info span')[i]).css 'display', 'none'

			if !$('#info span')[index]
				$('#info').css 'display', 'none'
			else
				$('#info').css 'display', 'block'
				$($('#info span')[index]).css 'display', 'inline-block'

			# set focus on iframe
			$('#content iframe').focus()


		onIframeLoad: ->
			# unbind load events
			$('#content iframe').unbind('load')

			# set focus on iframe
			$('#content iframe').focus()

			# hide overlay
			$('#overlay').animate {left:$(window).width(), width:0}, 1000, 'easeInOutQuint', ->
				$('#overlay').css 'display', 'none'


		updateBodyClass: (param) ->
			$('body').removeClass()
			$('body').addClass(param)


		addLeadingZero: (num) ->
			if (num < 10)
				return '0' + num
			num


		resize: =>
			wmenu = 0
			for i in [0...$('#menu').children().length]
				wmenu += $('#menu').children().eq(i).outerWidth(true)

			w = $(window).width() - $('#title').outerWidth(true) - $('#social').outerWidth(true) - wmenu - 1
			$('#info').outerWidth(w)
			return null


	window.onload = ->
		app.initMenu()

		$.address.change (e) ->
			# console.log '$.address.change', $.address.value()
			app.navTo($.address.value().substr(1, 2))

		# app.navTo($('#menu a')[0])
		# app.navTo($('#menu a')[0].innerHTML)

		# console.log 'window.onload', $.address.value()

		if !$.address.value().substr(1)
			$.address.value($('#menu a')[0].innerHTML)
		else app.navTo($.address.value().substr(1, 2))

		$(window).resize(app.resize)
		app.resize()