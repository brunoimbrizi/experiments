class ArrayUtils

	@shuffle: (array) ->
		counter = array.length
		temp = null
		index = null

		# While there are elements in the array
		while (counter--)
			# Pick a random index
			index = (Math.random() * counter) | 0

			# And swap the last element with it
			temp = array[counter]
			array[counter] = array[index]
			array[index] = temp

		return array