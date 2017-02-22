class MathUtils

	@map: (num, min1, max1, min2, max2, round = false, constrainMin = true, constrainMax = true) ->
		if (constrainMin && num < min1) then return min2
		if (constrainMax && num > max1) then return max2
		
		num1 = (num - min1) / (max1 - min1)
		num2 = (num1 * (max2 - min2)) + min2
		if (round) then return Math.round(num2)
		return num2


	@hexToRgb: (hex) ->
		result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
		if !result then return null

		r = parseInt(result[1], 16)
		g = parseInt(result[2], 16)
		b = parseInt(result[3], 16)
		rgb = r + ', ' + g + ', ' + b

		return { r:r, g:g, b:b, rgb:rgb }


	@rgbToHex: (r, g, b) ->
		return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)