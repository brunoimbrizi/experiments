class AppUtils


	@getSeconds: (str) ->
		# if str is not formated as 00:00
		if str.indexOf(':') < 0 then return 0

		a = str.split(':')

		# 00:00:00
		if a.length == 3
			s = (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2])
		# 00:00
		else if a.length == 2
			s = (+a[0]) * 60 + (+a[1])
		# 00
		else
			s = (+a[0])

		#return
		s


	@mercatorEncode: (lng, lat, mapSize = 0) ->
		# from https://snipt.net/tafaridh/mercator-latitude-longitude-to-x-y-point/
		lng = (+lng)
		lat = lat * Math.PI / 180

		if !mapSize then mapSize = AppData.MAP_SIZE
		mapw = maph = mapSize

		x = (mapw * (180 + lng) / 360) % mapw
		y = Math.log(Math.tan((lat * .5) + (Math.PI * .25)))
		y = (maph * .5) - (mapw * y / (2 * Math.PI))

		###
		# from https://gist.github.com/997450
		x = (lng - lonOrigin) / (2 * Math.PI)
		# while (x < 0) then x++
		y = 1 - (Math.log(Math.tan(Math.PI/4 + lat/2)) * 0.31830988618 + 1)/2
		###

		#return
		[x, y]


	# returns a value between 0 and 1 depending on train location
	# e.g. Between St. Paul's and Bank // returns 0.5
	@getTrainLocationValue: (location) ->
		value = 0
		
		if (location.indexOf('Between') == 0) then value = 0.5
		# else if (location.indexOf('Left') == 0) then value = 0.8
		# else if (location.indexOf('Approaching') == 0) then value = 0.2

		return value


	# returns station code of the last location
	# e.g. Between St. Paul's and Bank // returns STP
	@getTrainLastStation: (location) ->
		# test Between
		pattern = /Between\s(.+)\sand\s/
		result = pattern.exec(location)
		if (result) then stationName = result[1]

		# test At, Approaching, Left
		if (!stationName)
			pattern = /(At|Approaching|Left|)\s(.+)/
			result = pattern.exec(location)
			if (result) then stationName = result[2]
		
		if (!stationName) then return null

		station = app.stations.findWhere({ name:stationName })
		if (station) then return station.get('code')
		else console.log ('AppUtils.getTrainLastStation : stationName ' + stationName + ' not found.')