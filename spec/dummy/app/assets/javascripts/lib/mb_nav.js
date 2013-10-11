/* ---------------------- mb_nav.js  ------------------------------ */

/* ----- nav ----- */

// bergen: make body a variable

var mb_nav = {

  /* Set class variables for responsive nav */
  menuBtn: '.menu_button',
  navContainer: '#global_nav_container',
  subnavContainer: '.global_subnav_container',
  globalNav: '#global_nav',
  nav: '#nav',
  arrowBtn: '#global_nav .arrow_box',
  subnav: '.subnav',
  extendNavBtn: '#extend_nav_btn a',
  extendedNavContainer: '#extended_nav_container',
  extendedNav: '#extended_nav',
  

  /* Set instance variables for fake login */
  login: '.login :submit',
  login: '.logout :submit',
  
  /* Set defaults for mb_nav 
       BERGEN: if this is a < ie9 browser, defaultNavTopPos is always -1
  */
  defaultNavTopPos: -1,
  navHeight: 0,
  subnavHeight: 0,
  subnavPaddingBottom: 18,

  init: function(overrides) { 
    if (typeof overrides !== 'undefined') {
      for(var key in overrides) {
        mb_nav[key] = overrides[key];
      }
    }
    this._addNavArrows();  
    this._setDefaultStyles();
    this._initListeners();
  },
  
  /* Determine nav style by checking media query-based CSS changes */
  isHideable: function() {
    return $(mb_nav.menuBtn).is(':visible');
  },
    
  _initListeners: function() {

    // Mobile menu button click listener
    $(mb_nav.menuBtn).click(function() {
      //console.log("menuBtn clicked, toggling mobile nav. Is it hidden now? " + $('body').hasClass('mobile_menu_hidden'));
      mb_nav._toggleMobileNav();
    });
    
    $(mb_nav.arrowBtn).mouseover( function() {
      var thisSubnavContainer = $(this).parent().find(mb_nav.subnavContainer);        
    });
    
    // Mobile menu subnav arrow click listener (eventually put on all touch screens)
    $(mb_nav.arrowBtn).click( function() {
      var thisSubnavContainer = $(this).parent().find(mb_nav.subnavContainer);
      mb_nav._toggleMobileSubnav(thisSubnavContainer);
      $(this).toggleClass('reverse'); // turn the arrow upside down
    });
          
    // Load / resize / scroll listener
    //   removed "scroll" because scroll shouldn't affect nav styles
    //   removed "load" and calling just setDefault from init
    $(window).bind("resize", function() {
      mb_nav._setStylesToMatchNav();
    });
    
    // This is for a "more" button that adds additional nav to the mobile menu
    $(mb_nav.extendNavBtn).click( function() {
      mb_nav._toggleExtendedNav();
    });

    // Sticky nav listeners (except browsers worse than IE9)
    if (!$('html').hasClass('lt-ie9')) {
      $(window).bind("load resize", function() { 
        if (!mb_nav.isHideable()) mb_nav._setStickyNavBreakpoint();       
      });

      // Position the Persistent Sticky Nav
      $(window).bind("load resize scroll", function() { 
        if (!mb_nav.isHideable()) mb_nav._positionStickyNav();       
      });
    }
  },
      
  _addNavArrows: function () {
    $(mb_nav.subnav).parents('li').addClass('more-arrow');
    $('.more-arrow').prepend('<div class="arrow_box"><span class="arrow_down"></span></div>');
  },

  /*
   * Setting hideable(mobile)/persistent(desktop) nav styles
   */
  _setDefaultStyles: function () {
    if (mb_nav.isHideable()) {        
      mb_nav._setHideableNavStyles();
    } else {
      mb_nav._setPersistentNavStyles();
    }
  },
  _setHideableNavStyles: function () {
    $('body').removeClass('desktop_menu desktop_submenu_hidden').addClass('mobile_menu mobile_menu_hidden mobile_submenu_hidden');
  },
  _setPersistentNavStyles: function () {
    $('body').removeClass('mobile_menu mobile_menu_hidden mobile_submenu_hidden').addClass('desktop_menu desktop_submenu_hidden');
  },
  _setStylesToMatchNav: function () {
    //console.log("_setStylesToMatchNav isHideable()? " + mb_nav.isHideable());
    if (mb_nav.isHideable()) {        
      // If the nav is hideable
      // Make sure we're using 'mobile' classes
      //console.log("_setStylesToMatchNav $('body').hasClass('mobile_menu')? " + $('body').hasClass('mobile_menu'));
      //console.log("_setStylesToMatchNav $('body').hasClass('desktop_menu')? " + $('body').hasClass('desktop_menu'));
      if ($('body').hasClass('desktop_menu') || !$('body').hasClass('mobile_menu')) {
        //console.log("switching to mobile classes for nav");
        mb_nav._setHideableNavStyles();
      }
    } else {
      // If the nav is persistent
      // Make sure we're using 'desktop' classes
      if ($('body').hasClass('mobile_menu') && !$('body').hasClass('desktop_menu')) {
        //console.log("switching to desktop classes for nav");
        mb_nav._setPersistentNavStyles();
        $(mb_nav.subnavContainer).removeClass('expanded');        
      }
    }
  },
  
  _toggleMobileNav: function () {
    var $b = $('body');
    var $nc = $(mb_nav.navContainer);
    var $snc = $(mb_nav.subnavContainer);
    var $nav = $(mb_nav.globalNav);
    mb_nav.navHeight = $nav.height();
    var mobileMenuIsHidden = !$('body').hasClass('mobile_menu_visible');

    if (mobileMenuIsHidden) {
      // Show nav
      $nc.css('height', mb_nav.navHeight); 
      $b.removeClass('mobile_menu_hidden').addClass('mobile_menu_visible');
    } else {
      // Hide nav
      $b.addClass('mobile_submenu_hidden');
      $nc.css('height', 0); 
      $snc.css('height', 0).removeClass('expanded');
      $(mb_nav.arrowBtn).removeClass('reverse'); // Sets the nav arrows to down
      $b.removeClass('mobile_menu_visible').addClass('mobile_menu_hidden');
      mb_nav._resetExtendedNav();
    }
  },
  
  _toggleMobileSubnav: function ( thisSubnavContainer ) {
    var thisMobileSubmenuIsHidden = !$(thisSubnavContainer).hasClass('expanded');
    var $thisSubnav = $(thisSubnavContainer).find('.subnav');
    mb_nav.subnavHeight = $thisSubnav.height() + mb_nav.subnavPaddingBottom;
    if (thisMobileSubmenuIsHidden) {
      this._expandSubNav(thisSubnavContainer);
    } else {
      this._contractSubNav(thisSubnavContainer);
    }
  },
    
  _expandSubNav: function ( target ) {
    // Tell the body that there is a mobile submenu showing
    $('body').removeClass('mobile_submenu_hidden');
    $(target).addClass('expanded');

    var curH = $(mb_nav.navContainer).height();
    var subH = mb_nav.subnavHeight;
    var newH = (curH + subH).toString() + 'px';
    
    // Expand the height of the main menu
    $(mb_nav.navContainer).css('height', newH);
    // Expand the height of this submenu
    $(target).css('height', mb_nav.subnavHeight);
    
    // If this is within extended nav, make extended nav taller
    var isInExtendedNav = $(target).parent().parent().is(mb_nav.extendedNav);
    if (isInExtendedNav) {
      var newXnavH = $(mb_nav.extendedNav).height() + subH;
      mb_nav._setExtendedNavHeight(newXnavH);
    }
  },
  
  _contractSubNav: function ( target ) {    
    $(target).removeClass('expanded');
    
    // BERGEN commenting out. This should only happen if all submenus are closed
    // Browser testing may make us try to get this back in
    // $('body').addClass('mobile_submenu_hidden'); 

    var curH = $(mb_nav.navContainer).height();
    var subH = mb_nav.subnavHeight;
    var newH = (curH - subH).toString() + 'px';
    
    // Contract the height of the main menu
    $(mb_nav.navContainer).css('height', newH);
    
    // Contract the height of this submenu
    $(target).css('height', 0);
    
    // If this is within extended nav, make extended nav taller
    var isInExtendedNav = $(target).parent().parent().is(mb_nav.extendedNav);
    if (isInExtendedNav) {
      var newXnavH = $(mb_nav.extendedNav).height() - subH;
      mb_nav._setExtendedNavHeight(newXnavH);
    }
  },
  
  _toggleExtendedNav: function() {
     var $xNavC = $(mb_nav.extendedNavContainer);
     var $xNav = $(mb_nav.extendedNav);
     var curH = $(mb_nav.navContainer).height();
     var xNavH = $xNav.height();
     var newH = (curH + xNavH).toString() + 'px';

     if (!$xNav.hasClass('visible')) {
       $xNav.addClass('visible');
       $(mb_nav.navContainer).css('height', newH);
       mb_nav._setExtendedNavHeight(xNavH);
     } else {
       newH = (curH - xNavH).toString() + 'px';
       $xNav.removeClass('visible');
       $(mb_nav.navContainer).css('height', newH);
       mb_nav._setExtendedNavHeight(0);
     }
     
     // Change the button that displays (i.e. "more/less")
     $(mb_nav.extendNavBtn).toggleClass('hidden');
   },
   
  _resetExtendedNav: function() {
    var $xNav = $(mb_nav.extendedNav);
    if ($xNav.hasClass('visible')) {
      $xNav.removeClass('visible');
      $(mb_nav.extendNavBtn).toggleClass('hidden');
    }
  },
 
  _setExtendedNavHeight: function( px ) {
    $(mb_nav.extendedNavContainer).css('height', px);
  },
  
  // Set home base for sticky nav  
  _setStickyNavBreakpoint: function () {
    mb_nav.defaultNavTopPos = mb_utils.distanceFromTop(mb_nav.navContainer);
  },

  // Move sticky nav when visible window is below default nav position
  _positionStickyNav: function() {  
    var currentWindowTopPos = $(window).scrollTop();
    var navShouldBeSticky = mb_nav.defaultNavTopPos < currentWindowTopPos;
    if (navShouldBeSticky) {
      $(mb_nav.navContainer).css({ position: 'fixed', top: 0 }).addClass('dropshadow');
    } else {
      $(mb_nav.navContainer).css('position','static').removeClass('dropshadow');
      mb_nav._setStickyNavBreakpoint(); // BERGEN: this might not have to be set here. still sometimes new loads with sticky nav not working
    }
  },
    

  /*
   * Login/Logout States
   *
   * Should be handled server-side after integration
   */
  initFrontEndLoginState: function() {    
    $(mb_nav.login).click(function() {
      // Fake like we're seeing if they're logged in
      mb_nav._toggleLogin();
      return false;
    });
    
    $(mb_nav.logout).click(function() {
      mb_nav._toggleLogin();
      return false;
    });
  },

  _toggleLogin: function () {
    var isMobileMenu = $('body').hasClass('mobile_menu');
    var mobileMenuIsHidden = !$('body').hasClass('mobile_menu_visible');
    
    if ($('body').hasClass('logged_in')) {
      $('body').removeClass('logged_in').addClass('logged_out');
    } else {      
      $('body').removeClass('logged_out').addClass('logged_in');
    }
    
    if (mb_nav.isHideable() && !mobileMenuIsHidden) {
      this._toggleMobileNav();
    }
  },

  /*
   * Highlight Current Page in Nav
   *   Adds the "current" class name to a nav anchor if its href matches part of the URL
   *
   * Should be handled server-side after integration
   */
  initFrontEndNavHighlighting: function() {
    console.log('mb_nav.initFrontEndNavHighlighting');
    var $navAnchors = $('#id > a');
    var thisUrl = document.location.href;
    for (i = 0; i < $navAnchors.length; i++) {
      var navItemUrl = $navAnchors[i].href;
      if (thisUrl.indexOf(navItemUrl) >= 0) {
        $navAnchors[i].addClass('current');
      }
    }
  }

}

/* ----- end mb_nav.----- */