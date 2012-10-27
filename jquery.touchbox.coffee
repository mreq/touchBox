# doc ready wrap
$ ->
	# define plugin
	$.fn.touchBox = (customOptions) ->
		###############################	
		## override options
		###############################	
		options = $.extend {}, $.fn.touchBox.defaultOptions, customOptions
		items = this
		###############################	
		## helper variables
		###############################
		g =                # store globals there
			index: 0        # current index
			visible: false  # plugin starts hidden
			init: false     # plugin has to be initialized (on first click)
		# should we show arrows?
		showArrows = options.type is 'arrows'
		count = items.length
		min = 0 # min index
		max = count - 1 # max index
		if `('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch`
			isTouchDevice = true
		else
			isTouchDevice = false
		###############################	
		## DOM variables
		###############################	
		# overwrite type if invalid
		options.type = 'arrows' unless typeof options.type is 'string'
		body = $('body')
		wrap = $('<div class="touchBox hide type-'+options.type+'"></div>')
		wrap.addClass('absolute') if options.position is 'absolute'
		overlay = $('<div class="touchBox-overlay"></div>')
		box = $('<ul class="touchBox-ul"></ul>')
		if showArrows
			arrows = null
			leftArrow = null
			rightArrow = null
		placeholders = $([])
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
		toggleArrows = ->
			if g.index is 0
				leftArrow.addClass('hide')
			else
				leftArrow.removeClass('hide')
			if g.index is max
				rightArrow.addClass('hide')
			else
				rightArrow.removeClass('hide')
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
				img.css
					marginLeft: -w/2
					marginTop: -h/2
				img.addClass 'img-aligned'
		createArrows = ->
			leftArrow = $('<a href="#prev" class="touchBox-arrow touchBox-prev"><span></span></a>')
			rightArrow = $('<a href="#next" class="touchBox-arrow touchBox-next"><span></span></a>')
			return leftArrow.add(rightArrow)
		resize = ->
			wrap.find('.img-aligned').each ->
				alignImage $(this)
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
			if showArrows
				arrows = createArrows()
				wrap.append arrows
			body.append wrap
			moveToIndex index
			show index
			bindEvents()
			listenForEvents()
		show = (index) ->
			index = 0 unless index
			if g.init
				wrap.removeClass 'hide'
				moveToIndex index
			else
				init index
			wrap.trigger 'moved'
			g.visible = true
		hide = ->
			wrap.addClass 'hide'
			g.visible = false
		###############################	
		## listen for events
		###############################
		listenForEvents = ->
			wrap.on 'moved', ->
				toggleClasses()
				preloadImages()
				toggleArrows()
			wrap.on 'click', (e) ->
				hide() unless $(e.target).is 'img'
			wrap.on 'click', '.next .touchBox-image, .prev .touchBox-image', (e) ->
				if $(this).parent('.touchBox-placeholder').hasClass 'next'
					showNext()
				else
					showPrevious()
			$(window).on 'resize', resize
		###############################	
		## bind events
		###############################
		items.on 'click', (e) ->
			e.preventDefault()
			index = items.index this
			show index
		bindEvents = ->
			if showArrows
				arrows.on 'click', (e) ->
					e.preventDefault()
					e.stopPropagation()
					if $(this).hasClass('touchBox-prev')
						showPrevious()
					else
						showNext()
			$(window).on 'keydown', (e) ->
				if g.visible
					code = if e.keyCode then e.keyCode else e.which
					# left arrow
					showPrevious() if code is 37
					# right arrow
					showNext() if code is 39
					# escape
					hide() if code is 27
			if isTouchDevice
				$(document).on 'touchstart', '.touchBox', (e) ->
					touch = e.originalEvent
					startX = touch.changedTouches[0].pageX
					wrap.on 'touchmove', (e) ->
						e.preventDefault()
						touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0]
						if (touch.pageX - startX) > options.touchSensitivity
							wrap.off 'touchmove'
							showPrevious()
						else if (touch.pageX - startX) < -options.touchSensitivity
							wrap.off 'touchmove'
							showNext()

	# default options
	$.fn.touchBox.defaultOptions =
		imagesToPreload: 2
		position: 'fixed'
		touchSensitivity: 100
		type: 'arrows'
