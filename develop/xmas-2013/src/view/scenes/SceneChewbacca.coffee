class SceneChewbacca extends AbstractScene

	ctx 					: null
	index					: null
	reindeer 				: null


	constructor: (@ctx, @index) ->
		super

	update: ->
		super

		for a in @reindeer.anchors
			a.update()

	draw: ->
		hw = @ctx.width * .5
		hh = @ctx.height * .5
		scale = 1

		@ctx.globalCompositeOperation = 'source-over'

		for a in @reindeer.anchors
			@ctx.translate(hw, hh)
			a.draw()
			@ctx.setTransform(1, 0, 0, 1, 0, 0)


	initReindeer: ->
		super

		@reindeer.initRibbonAnchors()

		# set extra properties
		length = @reindeer.anchors.length
		for i in [0...length]
			a = @reindeer.anchors[i]

			a.color = 'rgb(20, ' + floor(random(50, 255)) + ', ' + floor(random(10, 50)) + ')'
			# a.color = 'rgb(' + floor(random(150, 255)) + ', ' + floor(random(150, 255)) + ', 25)'
			# a.color = 'rgb(' + floor(random(140, 200)) + ', ' + floor(random(50, 100)) + ', ' + floor(random(20, 50))+ ')'
			# a.color = '#000'
			# a.color = 'rgb(' + floor(random(20, 50)) + ', ' + (220 - floor((a.pos.y + 300) / 570 * 150)) + ', ' + floor(random(10, 50)) + ')'
			# a.color = 'rgb(140, ' + (245 - floor((a.pos.y + 300) / 570 * 150)) + ', ' + floor(random(20, 80))+ ')'
			a.radius = 4
			a.ctx = @ctx
			# a.length = 10 - (a.pos.y + 300) / 570 * 10
			# a.length = 8
			if (a.leftHead || a.leftHorn || a.rightHorn || a.rightHead) then a.length = 10
			else a.length = 5