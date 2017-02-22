class LineModel extends Backbone.Model

	defaults:
		code			: null
		name			: null
		color			: null
		branches		: null
		trains			: null
		date 			: null

	idAttribute			: 'code'
	gettingPrediction	: null


	getPredictionSummary: (fallback = false) ->
		@gettingPrediction = true

		@url = AppData.GET_PREDICTION_SUMMARY.replace('$code', @get('code'))
		if (fallback) then @url = AppData.FALLBACK_PREDICTION_SUMMARY.replace('$code', @get('code'))
		@fetch
			dataType: 'xml'
			success:	(model, reponse) =>
				console.log 'LineModel.getPredictionSummary success'#, model, reponse
				@trigger('loaded', @get('code'))
			error:		(model, reponse) =>
				console.log 'LineModel.getPredictionSummary error'#, model, reponse
				@getPredictionSummary(true)


	parse: (data) ->
		# parse only when getting PredictionSummary
		if !@gettingPrediction then return data

		parsed 			= {}
		parsed.trains 	= new TrainCollection()

		# <ROOT>
		$(data).children().children().each (index, item) =>
			# <Time>
			if item.nodeName == 'Time'
				timeStamp = $(item).attr('TimeStamp')
				time = timeStamp.substr(timeStamp.indexOf(' ') + 1)
				date = new Date()
				date.setHours(time.substr(0, 2))
				date.setMinutes(time.substr(3, 2))
				date.setSeconds(time.substr(6, 2))
				parsed.date = date
			# <S>
			if item.nodeName == 'S'
				sCode = $(item).attr('Code')
				sN = $(item).attr('N')
				# <P>
				$(item).children().each (p_index, p) =>
					pN = $(p).attr('N')
					# <T>
					$(p).children().each (t_index, t) =>
						$t = $(t)
						tS = $t.attr('S')
						tT = $t.attr('T')
						tD = $t.attr('D')
						tC = $t.attr('C')
						tL = $t.attr('L')
						tDE = $t.attr('DE')

						# if T="0", skip train
						if (tT != '0')
							# add train only if new
							train = parsed.trains.get(tS)
							if (!train || train.get('destination') != tDE)
								train = new TrainModel()
								train.set('id', tS)
								train.set('trip', tT)
								train.set('location', tL)
								train.set('destination', tDE)
								train.set('direction', pN)
								train.set('schedule', new ScheduleCollection())
								parsed.trains.push(train)

							scheduleCollection = train.get('schedule')
							station = app.stations.get(sCode)
							if station
								# skip if train appears twice in the same station
								if (!scheduleCollection.get(sCode))
									schedule = new ScheduleModel()
									# schedule.set('station', station)
									schedule.set('station', sCode)
									schedule.set('time', AppUtils.getSeconds(tC))
									scheduleCollection.push(schedule)

		
		toRemove = []
		parsed.trains.each (train) ->
			scheduleCollection = train.get('schedule')
	
			# mark train for removal if it only appears once
			if (scheduleCollection.length <= 1) then toRemove.push(train)

			# sort trains schedules by time
			scheduleCollection.sort()

		# remove trains marked for removal
		parsed.trains.remove(toRemove)

		# return
		parsed