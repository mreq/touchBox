# touchBox

a touch optimized jQuery lightbox

## Works in:
+ **Desktop**:
	+ Firefox, Chrome, Safari, Opera, IE7+
+ **Mobile**:
	+ Android Browser, Opera Mini, Firefox

## Getting started
1. Customize the variables in `jquery.touchbox.less`, build into css.
2. Include the plugin and dependencies.
3. Initialize the plugin by `$(jQueryObject).touchBox({options});`

## Options
+ `imagesToPreload` - Number of images to load in advance, in both directions.
+ `position` - use `fixed` (default) or `absolute` positioning
+ `touchSensitivity` - the amount of px the user has to slide with his finger to change images
+ `type` - can be `arrows` (default) or `thumbnails`
	+ with `arrows`, you get the two neat css arrows, which can be used to change images
	+ with `thumbnails`, pieces of neighboring images are shown and work as arrows