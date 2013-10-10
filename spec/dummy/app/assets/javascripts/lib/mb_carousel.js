//= require ./mb_swipe

/* ----- carousel ----- */

var carousel = {
	navButtons: null,

	init: function ( swipeArea, itemContainer, itemToSwipe, maxItems, excludedElements,nav_buttons, prev, next) {

		carousel.navButtons = nav_buttons;
		mb_swipe.init( swipeArea, itemContainer,itemToSwipe,maxItems, excludedElements, carousel.setNav);
		this.initListeners(nav_buttons, prev, next);
	},

	setNav: function(i){
		$(carousel.navButtons[i]).parent().find('.active').removeClass("active");
		$(carousel.navButtons[i]).addClass("active");
	},

	initListeners: function (nav_buttons, prev, next) {
		nav_buttons.each(function(i) {
			$(this).click(function(){
				mb_swipe.jumpToItem(i);
			});
		});

		prev.click(function(){
			mb_swipe.previousItem();
		});

		next.click(function(){
			mb_swipe.nextItem();
		});


	}
}

/* ----- end main ----- */