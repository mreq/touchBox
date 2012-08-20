// Generated by CoffeeScript 1.3.3
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $(function() {
    $.fn.touchBox = function(customOptions) {
      var all, arrows, body, box, count, extractUrlFrom, g, hide, init, isTouchDevice, isValidIndex, items, loadImage, makeASpring, makePlaceholders, max, min, moveToIndex, options, overlay, placeImage, placeholders, preloadImages, show, showNext, showPrevious, toggleArrows, wrap;
      options = $.extend({}, $.fn.touchBox.defaultOptions, customOptions);
      items = this;
      body = $('body');
      wrap = $("<div class=\"touchBox\" id=\"touchBox-" + window.touchBoxCount + "\"></div>");
      overlay = $('<div class="touchBox-overlay"></div>');
      all = wrap.add(overlay);
      box = $('<ul class="touchBox-ul"></ul>');
      arrows = {
        left: $('<div class="touchBox-arrow touchBox-left"></div>'),
        right: $('<div class="touchBox-arrow touchBox-right"></div>')
      };
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
      if (typeof window.touchBoxCount === 'undefined') {
        window.touchBoxCount = 0;
      } else {
        window.touchBoxCount++;
      }
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
      toggleArrows = function() {
        if (g.index === min) {
          return arrows.left.addClass('hide');
        } else {
          arrows.left.removeClass('hide');
          if (g.index === max) {
            return arrows.right.addClass('hide');
          } else {
            return arrows.right.removeClass('hide');
          }
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
      makePlaceholders = function() {
        return items.each(function(index) {
          return placeholders.add($("<li class=\"placeholder\" data-inde=\"" + index + "\"></li>"));
        });
      };
      loadImage = function(src, callback) {
        var img;
        img = $('<img alt="touchBox image" />').one('load', function() {
          return callback.call(img);
        });
        return img.attr({
          src: src
        });
      };
      placeImage = function(index) {
        var item, url;
        if (!isValidIndex(index)) {
          return false;
        }
        item = preloader.eq(index);
        url = extractUrlFrom(item);
        return loadImage(url, function() {
          return item.addClass('loaded').html(this);
        });
      };
      moveToIndex = function(index) {
        if (!isValidIndex(index)) {
          return false;
        }
        box.css({
          left: "-" + (100 * index) + "%"
        });
        g.index = indexpreloadThese;
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
        var high, low, preloadThese;
        low = g.index - options.imagesToPreload;
        if (low < min) {
          low = min;
        }
        high = g.index + options.imagesToPreload;
        if (high > max) {
          high = max;
        }
        preloadThese = placeholders.slice(low, high);
        return preloadThese.each(function() {
          return placeImage($(this));
        });
      };
      init = function(index) {
        if (!index) {
          index = 0;
        }
        g.init = true;
        makePlaceholders();
        box.append(placeholders);
        wrap.append(box);
        return body.append(all);
      };
      show = function(index) {
        if (!index) {
          index = 0;
        }
        if (g.init) {
          return all.removeClass('hide');
        } else {
          init(index);
          return all.removeClass('hide');
        }
      };
      hide = function() {
        return all.removeClass('hide');
      };
      wrap.on('moved', function() {
        toggleArrows();
        return preloadImages();
      });
      items.on('click', function(e) {
        var index;
        e.preventDefault();
        index = items.index(this);
        return show(index);
      });
      return $(window).on('keydown', function(e) {
        if (e.keyCode === 37) {
          showPrevious();
        }
        if (e.keyCode === 39) {
          showNext();
        }
        if (e.keyCode === 27) {
          return hideBox();
        }
      });
    };
    return $.fn.touchBox.defaultOptions = {
      imagesToPreload: 2
    };
  });

}).call(this);
