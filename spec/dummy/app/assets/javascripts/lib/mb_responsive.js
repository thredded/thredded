/* ----- Responsive Elements library: extending mb_utils ----- */

/* 
 * For elements that require specific/custom responsive movement
 * Register an element as responsive so it can move from its 
 * large display to its small display container 
 *
 * Currently limited to a basic 2-tier (large vs small) responsive setup
 *
 * mb_utils.js must precede this in the .js load order
 *
 * USAGE:
 *  Set up #search_module and two containers #primary_column and #secondary_column
 *  
 *  %script
 *    mb_utils.initResponsiveElement('#search_module', '#large_display_container', '#small_display_container');
 *     or
 *    mb_utils.initResponsiveElement('#search_module', '#large_display_container', '#small_display_container',450);
 */

$.extend(mb_utils, {
  initResponsiveElement: function( element, large_display_container, small_display_container, responsive_breakpoint ) {

    if (typeof responsive_breakpoint == 'undefined') {
      responsive_breakpoint = mb_responsive_utils.getResponsiveBreakpoint();
    }

    console.log("Registering Responsive Element: " + element, large_display_container, small_display_container, responsive_breakpoint);

    $(window).bind("load resize", function() { 
      mb_responsive_utils.moveResponsiveElements(element, large_display_container, small_display_container, responsive_breakpoint);
    })
  } 
});

// Populate main.js with this to set a default breakpoint for your site:

/* 
 * Responsive Breakpoint
 * Sets default breakpoint for classes which allow registering of responsive elements with 
 *    mb_utils.initResponsiveElement('#search_module', '#secondary_column', '#primary_column');
 * Requires mb_responsive.js
 */
//mb_responsive_utils.setResponsiveBreakpoint(769);

var mb_responsive_utils = {
  _responsive_breakpoint: 769, /* default */

  setResponsiveBreakpoint: function ( new_breakpoint ) {
    this._responsive_breakpoint = new_breakpoint;
  },
  getResponsiveBreakpoint: function (  ) {
    return this._responsive_breakpoint;
  },

  moveResponsiveElements: function ( element, large_display_container, small_display_container, responsiveBreakpoint ) { 
    var isSmall = $(window).width() < this._responsive_breakpoint;
    //console.log("window width: " + $(window).width() + " is small? " + isSmall);
    var target_container = isSmall ? small_display_container : large_display_container;
    mb_responsive_utils._moveElementIfNecessary(element, target_container);
  },    
  _moveElementIfNecessary: function ( element, targetContainer ) {
    if ($(targetContainer).attr('id')  != undefined && $(element).parent().attr('id') != undefined) {
      if ($(targetContainer).attr('id') != $(element).parent().attr('id')) { 
        console.log("Moving Responsive Element: " + element + " from #" + $(element).parent().attr('id') + " to " + targetContainer);
        $(element).prependTo(targetContainer);
      }
    } else {
      //console.log("Not Moving Responsive Element: " + element, $(element).parent(), $(element).parent().attr('id'), targetContainer);
    }
  }
}