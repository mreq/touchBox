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
		wrap.addClass('absolute') if options.position is 'absolute'
		overlay = $('<div class="touchBox-overlay"></div>')
		box = $('<ul class="touchBox-ul"></ul>')
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
			placeholders.width "#{ 100/count }%"
		###############################	
		## helper functions
		###############################	
		isValidIndex = (index) ->
			return false if index < min
			return false if index > max
			true
		extractUrlFrom = (item) ->
			return item.attr 'href'
		toggleClasses = ->
			placeholders.removeClass 'current prev next'
			placeholders.eq(g.index - 1).addClass 'prev'
			placeholders.eq(g.index).addClass 'current'
			placeholders.eq(g.index + 1).addClass 'next'
		makeASpring = (direction) ->
			className = "#{ direction }Spring"
			box.addClass className
			callback = ->
				box.removeClass className
			setTimeout callback, 500
		alignImage = (img) ->
			img.imagesLoaded ->
				w = img.width()
				h = img.height()
				img.removeClass 'not-aligned'
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
			img = $('<img class="touchBox-image not-aligned" alt="touchBox image" />').imagesLoaded ->
				callback.call img
			img.attr
				src: src
		# places img into prepared placeholder
		placeImage = (index) ->
			return false unless isValidIndex index
			placeholder = placeholders.eq index
			unless placeholder.hasClass('loaded')
				item = items.eq index
				url = extractUrlFrom item
				loadImage url, ->
					# `this` stands for the loaded img
					alignImage this
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
			while start <= end
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
			show index
		show = (index) ->
			index = 0 unless index
			if g.init
				wrap.removeClass 'hide'
			else
				init index
				wrap.removeClass 'hide'
			g.visible = true
		hide = ->
			wrap.addClass 'hide'
			g.visible = false
		###############################	
		## listen for events
		###############################
		wrap.on 'moved', ->
			toggleClasses()
			preloadImages()
		wrap.on 'click', (e) ->
			hide() unless $(e.target).is 'img'
		wrap.on 'click', '.next .touchBox-image, .prev .touchBox-image', (e) ->
			if $(this).parent('.touchBox-placeholder').hasClass 'next'
				showNext()
			else
				showPrevious()
		###############################	
		## bind events
		###############################
		items.on 'click', (e) ->
			e.preventDefault()
			index = items.index this
			show index
		$(window).on 'keydown', (e) ->
			if g.visible
				# left arrow
				showPrevious() if e.keyCode is 37
				# right arrow
				showNext() if e.keyCode is 39
				# escape
				hide() if e.keyCode is 27
		placeholders.on 'touchstart', (e) ->
			touch = e.originalEvent
			startX = touch.changedTouches[0].pageX
			placeholders.on 'touchmove', (e) ->
				e.preventDefault()
				touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0]
				if (touch.pageX - startX) > options.touchSensitivity
					placeholders.off 'touchmove'
					showPrevious()
				else if (touch.pageX - startX) < -options.touchSensitivity
					showNext()
					placeholders.off 'touchmove'

	# default options
	$.fn.touchBox.defaultOptions =
		imagesToPreload: 2
		position: 'fixed'
		touchSensitivity: 100
