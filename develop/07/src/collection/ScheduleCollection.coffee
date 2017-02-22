class ScheduleCollection extends Backbone.Collection

	model					: ScheduleModel

	comparator: (schedule) ->
		schedule.get('time')