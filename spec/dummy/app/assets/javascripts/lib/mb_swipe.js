var mb_swipe = {
	currentItemNum: 0,
	maxItems: 0,
	speed: 200,
	itemContainer: null,
	itemToSwipe: null,
	swipeArea: null,
	setNavFn: null,

	init:
	// Init touch swipe
		function ( swipeArea, itemContainer, itemToSwipe, maxItems, excludedElements, setNavFn) {
			this.swipeArea = swipeArea;
			this.itemContainer = itemContainer;
			this.itemToSwipe = itemToSwipe;
			this.maxItems = maxItems
			this.setNavFn = setNavFn
			this.initValues();
			this.initSwipe(excludedElements);
			this.setResizeListeners();
		},

	initValues:
		function () {
			// Set the width style on the container and item to be swiped based on the total number of items
			var containerW = 100*this.maxItems;
			var w1 = containerW.toString() + '%';
			var gap = 1/this.maxItems
			var itemW = 100/this.maxItems; //- gap ;
			var w2 = itemW.toString() + '%';
			mb_swipe.itemContainer.width(w1);
			mb_swipe.itemToSwipe.width(w2);
//			mb_swipe.itemToSwipe.css("margin-right", gap.toString() + '%');
		},

	initSwipe:
		function (excludedElements) {
			mb_swipe.swipeArea.swipe( {
				triggerOnTouchEnd : true,
				swipeStatus : mb_swipe.swipeStatus,
				allowPageScroll:"vertical",
				threshold: 75,
				excludedElements:$.fn.swipe.defaults.excludedElements +  ',' + excludedElements
			});



			// For iPhone, wrap video containers in a tags to allow tap on video (disables swipe on the video)
			if (isMobile.any() && $('figure').hasClass('detail_video')) {
				$('.detail_video').wrap('<a />');
			};


			// For iOS, add iOS class to entire page to handle hover issues with special classes
			if (isMobile.any()) {
				$('#page').addClass('mobile');
			}
		},

	/**
	 * Catch each phase of the swipe.
	 * move : we drag the div.
	 * cancel : we animate back to where we were
	 * end : we animate to the next image
	 */

	swipeStatus:
	function ( event, phase, direction, distance, fingers ) {

		//console.log('mb_swipe.swipeStatus.mb_swipe.itemToSwipe: ' + mb_swipe.itemToSwipe)

		var w = mb_swipe.itemToSwipe.width();

		//If we are moving before swipe, and we are going L or R, then manually drag the images
		if( phase=="move" && (direction=="left" || direction=="right") )
		{
			var duration=0;

			if (direction == "left")
				mb_swipe.slideItems((w * mb_swipe.currentItemNum) + distance, duration);

			else if (direction == "right")
				mb_swipe.slideItems((w * mb_swipe.currentItemNum) - distance, duration);
		}

		// Else, cancel means snap back to the begining
		else if ( phase == "cancel")
		{
			mb_swipe.slideItems(w * mb_swipe.currentItemNum, mb_swipe.speed);
		}

		// Else end means the swipe was completed, so move to the next image
		else if ( phase =="end" )
		{
			if (direction == "right")
				mb_swipe.previousItem()
			else if (direction == "left")
				mb_swipe.nextItem()
		}
	},

	slideToCurrentItem: function(){
		//offset = (this.itemContainer.width()/this.maxItems) * (.01/this.maxItems)
		offset = 0;
		var w = this.itemToSwipe.width() + offset * this.currentItemNum;
		this.slideItems( w * this.currentItemNum, this.speed);
	},

	previousItem:
		function () {
			var prevItemNum = this.currentItemNum-1;
			this.currentItemNum = Math.max(prevItemNum, 0);
			this.slideToCurrentItem();
			// Set the current nav button to the active state
			mb_swipe.setNavFn(this.currentItemNum);
		},

	nextItem:
		function () {
			var nextItemNum = this.currentItemNum+1;
			this.currentItemNum = Math.min(nextItemNum, this.maxItems-1);
			this.slideToCurrentItem();
			// Set the current nav button to the active state
			mb_swipe.setNavFn(this.currentItemNum);
		},

	jumpToItem:
		function (itemNum) {
			this.currentItemNum = Math.min(itemNum, this.maxItems-1);
			this.slideToCurrentItem();
			// Set the current nav button to the active state
			mb_swipe.setNavFn(this.currentItemNum);
			return false;
	},

	/**
	 * Manually update the position of the itemToSwipe on drag
	 */
	slideItems:
		function (distance, duration) {
			this.itemToSwipe.css("-webkit-transition-duration", (duration/1000).toFixed(1) + "s");

			// inverse the number we set in the css
			var value = (distance<0 ? "" : "-") + Math.abs(distance).toString();

			this.itemToSwipe.css("-webkit-transform", "translate3d("+value +"px,0px,0px)");

	},
	restoreAfterResize:
		function () {
			// When the window resizes, or mobile orientation changes,
			// we restore the correct positioning of the detail view
			// so it doesn't slide offscreen.

			var w = this.itemToSwipe.width();
			console.log('mb_swipe.restoreAfterResize()');
			this.slideItems( w * this.currentItemNum, this.speed);
	},
	setResizeListeners: function() {
		$(window).resize(function() {

			var delay = 500;

			if (isMobile.any()) {
				delay = 0;
			}

			if(this.resizeTO) clearTimeout(this.resizeTO);
			this.resizeTO = setTimeout(function() {
				$(this).trigger('resizeEnd');
			}, delay);
		});

		$(window).bind('resizeEnd', function() {

			console.log('resize');

			//do something, window hasn't changed size in 500ms
			mb_swipe.restoreAfterResize();

		});
	}


}

