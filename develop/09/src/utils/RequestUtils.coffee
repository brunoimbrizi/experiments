class RequestUtils

	@loadJSON = (url, callback) ->
		xobj = new XMLHttpRequest()
		xobj.overrideMimeType 'application/json'
		xobj.open 'GET', url, true
		xobj.onreadystatechange = ->

			# Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
			callback xobj.responseText  if xobj.readyState is 4 and xobj.status is '200'
			return

		xobj.send null
		return