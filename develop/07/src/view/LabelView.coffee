class LabelView

	ctx						: null
	code					: null
	label					: null
	badge					: null
	lineIndex				: null
	color					: null

	box						: null
	arw						: null
	img						: null
	txt						: null

	pos						: null

	showed					: false

	BOX_HEIGHT				: 34
	ARW_WIDTH				: 20
	ARW_HEIGHT				: 10
	IMG_WIDTH				: 20
	IMG_HEIGHT				: 18

	constructor: (@ctx) ->
		@box = { x:0, y:0, w:0, h:0 }
		@arw = { x:0, y:0, w:0, h:0 }
		@txt = { x:0, y:0, w:0, h:0 }
		@img = { x:0, y:0, w:0, h:0 }
		@pos = { x:100, y:100 }

		@badge = new Image()
		@badge.onload = =>
			@img.w = @badge.width
		@badge.src = 'img/badges.png'

		@arw.w = @ARW_WIDTH
		@arw.h = @ARW_HEIGHT

		@color = '#666'


	draw: ->
		if (!@showed) then return

		boxX = @box.x + @pos.x
		boxY = @box.y + @pos.y
		arwX = @arw.x + @pos.x
		arwY = @arw.y + @pos.y
		imgX = @img.x + @pos.x
		imgY = @img.y + @pos.y
		txtX = @txt.x + @pos.x
		txtY = @txt.y + @pos.y

		@ctx.beginPath()

		@ctx.moveTo(boxX, boxY)
		@ctx.lineTo(boxX, boxY + @box.h)
		@ctx.lineTo(arwX, boxY + @box.h)
		@ctx.lineTo(arwX + @arw.w * .5, arwY + @arw.h)
		@ctx.lineTo(arwX + @arw.w, boxY + @box.h)
		@ctx.lineTo(boxX + @box.w, boxY + @box.h)
		@ctx.lineTo(boxX + @box.w, boxY)
		@ctx.lineTo(boxX, boxY)

		@ctx.strokeStyle = @color
		@ctx.fillStyle = 'rgba(0, 0, 0, 0.7)'
		@ctx.stroke()
		@ctx.fill()
		@ctx.closePath()

		@ctx.globalCompositeOperation = 'source-atop'

		@ctx.drawImage(@badge, 0, @IMG_HEIGHT * @lineIndex, @IMG_WIDTH, @IMG_HEIGHT, imgX, imgY, @IMG_WIDTH, @IMG_HEIGHT)

		@ctx.fillStyle = @color
		@ctx.font = '12px Monda'
		@ctx.fillText(@label, txtX, txtY)

		@ctx.globalCompositeOperation = 'source-over'


	show: (@code, @label, @color, @lineIndex) ->
		@showed = true

		@label = @label.toUpperCase()
		@ctx.font = '12px Monda'
		@txt.w = @ctx.measureText(@label).width

		# box
		@box.x = @box.y = 0
		@box.w = @box.h = 0
		
		boxW = @txt.w + 60
		boxH = @BOX_HEIGHT
		boxX = @box.x - (boxW * .5)
		boxY = @box.y - boxH - @ARW_HEIGHT * 2
		
		TweenLite.to(@box, 0.4, { x:boxX, w:boxW })
		TweenLite.to(@box, 0.4, { y:boxY, h:boxH, ease:Quart.easeInOut, onUpdate: =>
			@arw.y = @box.y + @box.h
		})

		# arrow
		arwW = @ARW_WIDTH
		arwH = @ARW_HEIGHT

		@arw.x = @box.x - (arwW * .5)
		@arw.y = @box.y - @box.h
		@arw.h = 0

		TweenLite.to(@arw, 0.3, { h:arwH, ease:Quart.easeOut, delay:0.2 })

		# image
		@img.x = boxX + 14
		@img.y = @box.y + 50

		TweenLite.to(@img, 0.4, { y:boxY + 8, ease:Expo.easeOut, delay:0.2 })

		# label
		@txt.x = @img.x + @img.w + 9
		@txt.y = @box.y + 100

		TweenLite.to(@txt, 0.4, { y:boxY + 21, ease:Expo.easeOut, delay:0.1 })


	hide: (immediate = true) ->
		if (immediate)
			@showed = false
			return

		# @txt.y = 100
		# @img.y = 100
		
		boxW = @box.w * .9
		boxH = @BOX_HEIGHT
		boxX = @box.x + ((@box.w - boxW) * .5)
		boxY = @box.y + 10

		TweenLite.to(@box, 0.2, { x:boxX, w:boxW, y:boxY, h:2, ease:Expo.easeIn, onUpdate: =>
			@arw.y = @box.y + @box.h
			@arw.h -= 0.5
		, onComplete: =>
			@showed = false
		})

		
		