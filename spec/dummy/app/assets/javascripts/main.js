/* ---------------------- NIGHT SKY NETWORK - main.js  ------------------------------ */


/* ----- main ----- */

var main = {
  init: function() {
	  	/**
	     * Our core utils
	     * Requires: mb_utils.js
	     */
	    mb_utils.init();

	    /**
	     * Our nav instance.
	     * Requires: mb_nav.js
	     * Override with:     
	     *   var overrides = { menuBtn: '.menu_button', navContainer: '#global_nav_container' }
	     *   nav.init(overrides);
	     */
	    mb_nav.init();

	    /**
	     * Make touchscreen touches respond faster 
	     * Requires vendor/fastclick.js
	     */
	    FastClick.attach(document.body);
            
      /*
       * Front-end helpers
       *   May not be desired after integration with backend
       */
      mb_nav.initFrontEndNavHighlighting();

      /*
       * Custom instance code
       */
      this._initListeners();
			this._setDefaultLayout();//this.setListGridView();
    }, 
    
   //jh added 9-3-13
  _initListeners: function () {
		$('.modal_button').click(function(){
			$('.modal_content').modal();
		});
		$('.show_caption').click(function(){
			$(this).toggleClass('wane');
		});
		$('.nav_item.list_icon').click(function(){
			main.setLayout('list_view');
		});
		$('.nav_item.grid_icon').click(function(){
			main.setLayout('grid_view');
		});
    $('.more_button a').click(function(){
      var page = $('body').attr('id');
      var last_li = $('ul.articles').children('li:last');
      more_items.getMoreItemsAndAppendTo(page,last_li);
      return false;
    })
	},

  /*
   * Set a css class on the body element to determine layout of list/grid pages
   */
	setLayout: function(layout_class) {
		$('body').removeClass('grid_view list_view').addClass(layout_class);
		mb_utils.createCookie($('body').attr('id'), layout_class, 30);
	},

	_setDefaultLayout: function() {
		var page_id = $('body').attr('id');
		var layout_class = mb_utils.readCookie(page_id);
		if (layout_class == null) {
			switch(page_id) {
				case "images":
				case "videos":
				  layout_class = "grid_view";
				case "news":
				case "missions":
				default:
				  layout_class = "list_view";
			}
		}
		this.setLayout(layout_class);
	}
}

/* ----- end main ----- */




/* ----- ON READY ----- */

$(function(){
  main.init();
});

/* ----- end ON READY ----- */
