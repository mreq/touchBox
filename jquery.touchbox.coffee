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
		wrap = $('<div class="touchBox hide"></div>')
		overlay = $('<div class="touchBox-overlay"></div>')
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
		###############################	
		## init actions
		###############################
		makePlaceholders = ->
			items.each (index) ->
				placeholders = placeholders.add $("<li class=\"touchBox-placeholder\" data-index=\"#{ index }\"></li>")
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
		alignImage = (img) ->
			w = img.width()
			h = img.height()
			img.attr
				width: w
				height: h
			img.css
				marginLeft: -w/2
				marginTop: -h/2
		###############################	
		## private functions
		###############################
		# loads img, calls callback afterwards
		loadImage = (src, callback) ->
			img = $('<img alt="touchBox image" class="touchBox-image" />').one 'load', ->
				alignImage img
				console.log img
				callback.call img
			img.attr
				src: src
		# places img into itemprepared placeholder
		placeImage = (index) ->
			return false unless isValidIndex index
			item = items.eq index
			placeholder = placeholders.eq index
			url = extractUrlFrom item
			loadImage url, ->
				placeholder.addClass('loaded').html this
		# moves the box to the item specified by index
		moveToIndex = (index) ->
			return false unless isValidIndex index
			box.css
				left: "-#{ 100*index }%"
			g.index = index
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
			start = g.index - options.imagesToPreload
			start = min if start < min
			end = g.index + options.imagesToPreload
			end = max if end > max
			while start < end
				placeImage start
				start++

		init = (index) ->
			index = g.index unless index
			if typeof window.touchBoxCount is 'undefined'
				window.touchBoxCount = 0
			else
				window.touchBoxCount++
			g.init = true
			makePlaceholders()
			box.append placeholders
			box.width "#{ count*100 }%"
			wrap.attr
				id: "touchBox-#{ window.touchBoxCount }"
			wrap.append overlay
			wrap.append box
			body.append wrap
			moveToIndex index
			show()
		show = (index) ->
			index = 0 unless index
			if g.init
				wrap.removeClass 'hide'
			else
				init index
				wrap.removeClass 'hide'
		hide = ->
			wrap.removeClass 'hide'
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
		overlay.on 'click', hide

		init()

	# default options
	$.fn.touchBox.defaultOptions =
		imagesToPreload: 2
