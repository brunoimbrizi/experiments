class AppData

	# server
	@IS_LOCAL						: false

	# service
	@GET_LINES						: 'json/lines.json'
	@GET_STATIONS					: 'json/stations.json'
	# @GET_PREDICTION_SUMMARY			: 'xml/$code.xml'
	# @GET_PREDICTION_SUMMARY			: 'http://cloud.tfl.gov.uk/TrackerNet/PredictionSummary/$code'
	@GET_PREDICTION_SUMMARY			: 'proxy/?line=$code'
	@FALLBACK_PREDICTION_SUMMARY	: 'xml/$code.xml'

	# map
	@MAP_SIZE						: 500000