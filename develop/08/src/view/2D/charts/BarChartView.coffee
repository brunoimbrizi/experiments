class BarChartView

	view 					: null
	ctx						: null
	pos						: null
	values					: null

	iSelected				: null
	eSelected				: null


	constructor: (@ctx) ->
		@view = app.view


	update: (@values, @iSelected = -1, @eSelected = -1) ->


	draw: ->
		length = @values.length
		y = @view.sketch.height
		w = @view.sketch.width / length - 1
		h = 300

		for i in [0...length]
			@ctx.fillStyle = 'rgba(255, 255, 255, 0.1)'
			if (i >= @iSelected && i < @eSelected) then @ctx.fillStyle = 'rgba(255, 255, 255, 0.3)'
			@ctx.fillRect(i * (w + 1), y, w, @values[i] * -h - 10)