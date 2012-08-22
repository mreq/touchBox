// Generated by CoffeeScript 1.3.3
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $(function() {
    $.fn.touchBox = function(customOptions) {
      var alignImage, body, box, count, extractUrlFrom, g, hide, init, isTouchDevice, isValidIndex, items, loadImage, makeASpring, makePlaceholders, max, min, moveToIndex, options, overlay, placeImage, placeholders, preloadImages, show, showNext, showPrevious, toggleClasses, wrap;
      options = $.extend({}, $.fn.touchBox.defaultOptions, customOptions);
      items = this;
      body = $('body');
      wrap = $('<div class="touchBox hide"></div>');
      if (options.position === 'absolute') {
        wrap.addClass('absolute');
      }
      overlay = $('<div class="touchBox-overlay"></div>');
      box = $('<ul class="touchBox-ul"></ul>');
      placeholders = $([]);
      g = {
        index: 0,
        visible: false,
        init: false
      };
      count = items.length;
      min = 0;
      max = count - 1;
      isTouchDevice = __indexOf.call(window, 'ontouchstart') >= 0;
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
          img.attr({
            width: w,
            height: h
          });
          return img.css({
            marginLeft: -w / 2,
            marginTop: -h / 2
          });
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
        body.append(wrap);
        moveToIndex(index);
        return show(index);
      };
      show = function(index) {
        if (!index) {
          index = 0;
        }
        if (g.init) {
          moveToIndex(index);
          wrap.removeClass('hide');
        } else {
          init(index);
          wrap.removeClass('hide');
        }
        return g.visible = true;
      };
      hide = function() {
        wrap.addClass('hide');
        return g.visible = false;
      };
      wrap.on('moved', function() {
        toggleClasses();
        return preloadImages();
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
      items.on('click', function(e) {
        var index;
        e.preventDefault();
        index = items.index(this);
        return show(index);
      });
      $(window).on('keydown', function(e) {
        if (g.visible) {
          if (e.keyCode === 37) {
            showPrevious();
          }
          if (e.keyCode === 39) {
            showNext();
          }
          if (e.keyCode === 27) {
            return hide();
          }
        }
      });
      if (isTouchDevice) {
        return placeholders.on('touchstart', function(e) {
          var startX, touch;
          touch = e.originalEvent;
          startX = touch.changedTouches[0].pageX;
          return placeholders.on('touchmove', function(e) {
            e.preventDefault();
            touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
            if ((touch.pageX - startX) > options.touchSensitivity) {
              placeholders.off('touchmove');
              return showPrevious();
            } else if ((touch.pageX - startX) < -options.touchSensitivity) {
              showNext();
              return placeholders.off('touchmove');
            }
          });
        });
      }
    };
    return $.fn.touchBox.defaultOptions = {
      imagesToPreload: 2,
      position: 'fixed',
      touchSensitivity: 100
    };
  });

}).call(this);
