# doc ready wrap
$ ->
	# define plugin
	$.fn.touchBox = (customOptions) ->
		###############################	
		## override options
		###############################	
		options = $.extend {}, $.fn.touchBox.defaultOptions, customOptions
		###############################	
		## DOM variables
		###############################	
		items = this
		body = $('body')
		wrap = $("<div class=\"touchBox\" id=\"touchBox-#{ window.touchBoxCount }\"></div>")
		overlay = $('<div class="touchBox-overlay"></div>')
		all = wrap.add overlay
		box = $('<ul class="touchBox-ul"></ul>')
		arrows =
			left: $('<div class="touchBox-arrow touchBox-left"></div>')
			right: $('<div class="touchBox-arrow touchBox-right"></div>')
		placeholders = $([])
		###############################	
		## helper variables
		###############################
		g =                # store globals there
			index: 0        # current index
			visible: false  # plugin starts hidden
			init: false     # plugin has to be initialized (on first click)
		count = items.length
		min = 0 # min index
		max = count - 1 # max index
		isTouchDevice = 'ontouchstart' in window
		if typeof window.touchBoxCount is 'undefined'
			window.touchBoxCount = 0
		else
			window.touchBoxCount++
		###############################	
		## helper functions
		###############################	
		isValidIndex = (index) ->
			return false if index < min
			return false if index > max
			true
		extractUrlFrom = (item) ->
			return item.attr 'href'
		toggleArrows = ->
			if g.index is min
				arrows.left.addClass 'hide'
			else
				arrows.left.removeClass 'hide'
				if g.index is max
					arrows.right.addClass 'hide'
				else
					arrows.right.removeClass 'hide'
		makeASpring = (direction) ->
			className = "#{ direction }Spring"
			box.addClass className
			callback = ->
				box.removeClass className
			setTimeout callback, 500
		makePlaceholders = ->
			items.each (index) ->
				placeholders.add $("<li class=\"placeholder\" data-inde=\"#{ index }\"></li>")
		###############################	
		## private functions
		###############################
		# loads img, calls callback afterwards
		loadImage = (src, callback) ->
			img = $('<img alt="touchBox image" />').one 'load', ->
				callback.call img
			img.attr
				src: src
		# places img into prepared placeholder
		placeImage = (index) ->
			return false unless isValidIndex index
			item = preloader.eq index
			url = extractUrlFrom item
			loadImage url, ->
				item.addClass('loaded').html this
		# moves the box to the item specified by index
		moveToIndex = (index) ->
			return false unless isValidIndex index
			box.css
				left: "-#{ 100*index }%"
			g.index = indexpreloadThese
			wrap.trigger 'moved'
		showNext = ->
			index = g.index + 1
			if isValidIndex index
				moveToIndex index
			else # not a valid index, make a spring
				makeASpring 'right'
		showPrevious = ->
			index = g.index - 1
			if isValidIndex index
				moveToIndex index
			else # not a valid index, make a spring
				makeASpring 'left'
		# preloads the neighboring images
		preloadImages = ->
			low = g.index - options.imagesToPreload
			low = min if low < min
			high = g.index + options.imagesToPreload
			high = max if high > max
			preloadThese = placeholders.slice low, high
			preloadThese.each ->
				placeImage $(this)

		init = (index) ->
			index = 0 unless index
			g.init = true
			makePlaceholders()
			box.append placeholders
			wrap.append box
			body.append all
		show = (index) ->
			index = 0 unless index
			if g.init
				all.removeClass 'hide'
			else
				init index
				all.removeClass 'hide'
		hide = ->
			all.removeClass 'hide'
		###############################	
		## listen for events
		###############################
		wrap.on 'moved', ->
			toggleArrows()
			preloadImages()
		###############################	
		## bind events
		###############################
		items.on 'click', (e) ->
			e.preventDefault()
			index = items.index this
			show index
		$(window).on 'keydown', (e) ->
			# left arrow
			showPrevious() if e.keyCode is 37
			# right arrow
			showNext() if e.keyCode is 39
			# escape
			hideBox() if e.keyCode is 27


	# default options
	$.fn.touchBox.defaultOptions =
		imagesToPreload: 2
