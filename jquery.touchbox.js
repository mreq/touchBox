// Generated by CoffeeScript 1.3.3
(function() {

  $(function() {
    $.fn.touchBox = function(customOptions) {
      var alignImage, arrows, bindEvents, body, box, count, createArrows, extractUrlFrom, g, hide, init, isTouchDevice, isValidIndex, items, leftArrow, listenForEvents, loadImage, makeASpring, makePlaceholders, max, min, moveToIndex, options, overlay, placeImage, placeholders, preloadImages, resize, rightArrow, show, showArrows, showNext, showPrevious, toggleArrows, toggleClasses, wrap;
      options = $.extend({}, $.fn.touchBox.defaultOptions, customOptions);
      items = this;
      g = {
        index: 0,
        visible: false,
        init: false
      };
      showArrows = options.type === 'arrows';
      count = items.length;
      min = 0;
      max = count - 1;
      if (('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch) {
        isTouchDevice = true;
        showArrows = false;
      } else {
        isTouchDevice = false;
      }
      if (typeof options.type !== 'string') {
        options.type = 'arrows';
      }
      body = $('body');
      wrap = $('<div class="touchBox hide type-' + options.type + '"></div>');
      if (options.position === 'absolute') {
        wrap.addClass('absolute');
      }
      overlay = $('<div class="touchBox-overlay"></div>');
      box = $('<ul class="touchBox-ul"></ul>');
      if (showArrows) {
        arrows = null;
        leftArrow = null;
        rightArrow = null;
      }
      placeholders = $([]);
      makePlaceholders = function() {
        items.each(function(index) {
          return placeholders = placeholders.add($("<li class=\"touchBox-placeholder\" data-index=\"" + index + "\"></li>"));
        });
        return placeholders.width("" + (100 / count) + "%");
      };
      isValidIndex = function(index) {
        if (index < min) {
          return false;
        }
        if (index > max) {
          return false;
        }
        return true;
      };
      extractUrlFrom = function(item) {
        return item.attr('href');
      };
      toggleClasses = function() {
        placeholders.removeClass('current prev next');
        placeholders.eq(g.index - 1).addClass('prev');
        placeholders.eq(g.index).addClass('current');
        return placeholders.eq(g.index + 1).addClass('next');
      };
      toggleArrows = function() {
        if (g.index === 0) {
          leftArrow.addClass('hide');
        } else {
          leftArrow.removeClass('hide');
        }
        if (g.index === max) {
          return rightArrow.addClass('hide');
        } else {
          return rightArrow.removeClass('hide');
        }
      };
      makeASpring = function(direction) {
        var callback, className;
        className = "" + direction + "Spring";
        box.addClass(className);
        callback = function() {
          return box.removeClass(className);
        };
        return setTimeout(callback, 500);
      };
      alignImage = function(img) {
        return img.imagesLoaded(function() {
          var h, w;
          w = img.width();
          h = img.height();
          img.removeClass('not-aligned');
          img.css({
            marginLeft: -w / 2,
            marginTop: -h / 2
          });
          return img.addClass('img-aligned');
        });
      };
      createArrows = function() {
        leftArrow = $('<a href="#prev" class="touchBox-arrow touchBox-prev"><span></span></a>');
        rightArrow = $('<a href="#next" class="touchBox-arrow touchBox-next"><span></span></a>');
        return leftArrow.add(rightArrow);
      };
      resize = function() {
        return wrap.find('.img-aligned').each(function() {
          return alignImage($(this));
        });
      };
      loadImage = function(src, callback) {
        var img;
        img = $('<img class="touchBox-image not-aligned" alt="touchBox image" />').imagesLoaded(function() {
          return callback.call(img);
        });
        return img.attr({
          src: src
        });
      };
      placeImage = function(index) {
        var item, placeholder, url;
        if (!isValidIndex(index)) {
          return false;
        }
        placeholder = placeholders.eq(index);
        if (!placeholder.hasClass('loaded')) {
          item = items.eq(index);
          url = extractUrlFrom(item);
          return loadImage(url, function() {
            alignImage(this);
            return placeholder.addClass('loaded').html(this);
          });
        }
      };
      moveToIndex = function(index) {
        if (!isValidIndex(index)) {
          return false;
        }
        box.css({
          left: "-" + (100 * index) + "%"
        });
        g.index = index;
        return wrap.trigger('moved');
      };
      showNext = function() {
        var index;
        index = g.index + 1;
        if (isValidIndex(index)) {
          return moveToIndex(index);
        } else {
          return makeASpring('right');
        }
      };
      showPrevious = function() {
        var index;
        index = g.index - 1;
        if (isValidIndex(index)) {
          return moveToIndex(index);
        } else {
          return makeASpring('left');
        }
      };
      preloadImages = function() {
        var end, start, _results;
        start = g.index - options.imagesToPreload;
        if (start < min) {
          start = min;
        }
        end = g.index + options.imagesToPreload;
        if (end > max) {
          end = max;
        }
        _results = [];
        while (start <= end) {
          placeImage(start);
          _results.push(start++);
        }
        return _results;
      };
      init = function(index) {
        if (!index) {
          index = g.index;
        }
        if (typeof window.touchBoxCount === 'undefined') {
          window.touchBoxCount = 0;
        } else {
          window.touchBoxCount++;
        }
        g.init = true;
        makePlaceholders();
        box.append(placeholders);
        box.width("" + (count * 100) + "%");
        wrap.attr({
          id: "touchBox-" + window.touchBoxCount
        });
        wrap.append(overlay);
        wrap.append(box);
        if (showArrows) {
          arrows = createArrows();
          wrap.append(arrows);
        }
        body.append(wrap);
        moveToIndex(index);
        show(index);
        bindEvents();
        return listenForEvents();
      };
      show = function(index) {
        if (!index) {
          index = 0;
        }
        if (g.init) {
          wrap.removeClass('hide');
          moveToIndex(index);
        } else {
          init(index);
        }
        wrap.trigger('moved');
        return g.visible = true;
      };
      hide = function() {
        wrap.addClass('hide');
        return g.visible = false;
      };
      listenForEvents = function() {
        wrap.on('moved', function() {
          toggleClasses();
          preloadImages();
          return toggleArrows();
        });
        wrap.on('click', function(e) {
          if (!$(e.target).is('img')) {
            return hide();
          }
        });
        wrap.on('click', '.next .touchBox-image, .prev .touchBox-image', function(e) {
          if ($(this).parent('.touchBox-placeholder').hasClass('next')) {
            return showNext();
          } else {
            return showPrevious();
          }
        });
        return $(window).on('resize', resize);
      };
      items.on('click', function(e) {
        var index;
        e.preventDefault();
        index = items.index(this);
        return show(index);
      });
      return bindEvents = function() {
        if (showArrows) {
          arrows.on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            if ($(this).hasClass('touchBox-prev')) {
              return showPrevious();
            } else {
              return showNext();
            }
          });
        }
        $(window).on('keydown', function(e) {
          var code;
          if (g.visible) {
            code = e.keyCode ? e.keyCode : e.which;
            if (code === 37) {
              showPrevious();
            }
            if (code === 39) {
              showNext();
            }
            if (code === 27) {
              return hide();
            }
          }
        });
        if (isTouchDevice) {
          return $(document).on('touchstart', '.touchBox', function(e) {
            var startX, touch;
            touch = e.originalEvent;
            startX = touch.changedTouches[0].pageX;
            return wrap.on('touchmove', function(e) {
              e.preventDefault();
              touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
              if ((touch.pageX - startX) > options.touchSensitivity) {
                wrap.off('touchmove');
                return showPrevious();
              } else if ((touch.pageX - startX) < -options.touchSensitivity) {
                wrap.off('touchmove');
                return showNext();
              }
            });
          });
        }
      };
    };
    return $.fn.touchBox.defaultOptions = {
      imagesToPreload: 2,
      position: 'fixed',
      touchSensitivity: 100,
      type: 'arrows'
    };
  });

}).call(this);
