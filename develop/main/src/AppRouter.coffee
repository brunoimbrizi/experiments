class AppRouter extends Backbone.Router

	id 					: null

	routes:
		':id'			: 'hashChanged'
		':id/'			: 'hashChanged'
		'/:id'			: 'hashChanged'
		'/:id/'			: 'hashChanged'

		'*actions'		: 'default'


	hashChanged: (id = null) =>
		console.log 'AppRouter.hashChanged', id
		# @trigger window.app.EVENT_HASH_CHANGED, id


	default: (actions = null) ->
		# @hashChanged('01')


	init: ->
		# Backbone.history.start { pushState:false }
		console.log 'AppRouter.init', Backbone.history
		Backbone.history.start()