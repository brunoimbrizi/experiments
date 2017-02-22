class StringUtils

	@addLeadingZero: (num, zeros = 1) ->
		string = String(num)
		
		for i in [0...zeros]
			if (num < Math.pow(10, (i + 1)) && num > -1) then string = '0' + string
		
		return string


	@formatTime: (milliseconds, showHours = true, showMinutes = true, showSeconds = true, showDecimals = false) ->
		s = Math.floor(milliseconds / 1000)
		m = Math.floor(s / 60)
		h = Math.floor(m / 60)
		d = Math.floor(milliseconds % 1000)
		string = ''

		if (showHours) then string += @addLeadingZero(h)
		if (showHours && showMinutes) then string += ':'
		if (showMinutes) then string += @addLeadingZero(m % 60)
		if (showMinutes && showSeconds) then string += ':'
		if (showSeconds) then string += @addLeadingZero(s % 60)
		if (showSeconds && showDecimals) then string += '.'
		if (showDecimals) then string += @addLeadingZero(d, 2).substr(0, 2)
		
		return string