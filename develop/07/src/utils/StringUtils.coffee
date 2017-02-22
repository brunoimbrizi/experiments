class StringUtils

	@addLeadingZero: (num, zeros = 1) ->
			string = String(num)
			
			for i in [0...zeros]
				if (num < Math.pow(10, (i + 1)) && num > -1) then string = '0' + string
			
			return string