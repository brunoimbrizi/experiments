class StationModel extends Backbone.Model

	defaults:
		code			: null
		name			: null
		number			: null
		lines			: null
		platforms		: null
		location		: null
		position		: null

	idAttribute			: 'code'