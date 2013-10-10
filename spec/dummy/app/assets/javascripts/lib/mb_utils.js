/* ---------------------- NIGHT SKY NETWORK - mb_utils.js  ------------------------------ */

/* ----- mb_utils ----- */

var mb_utils = {

  init: function() { 
      this._extendJquery();
    },
    
  _extendJquery: function () {
    // exists function returns a boolean ... use example: $('body').exists();
    jQuery.fn.exists = function () { return this.length>0; }
  },

  /* 
   * SlideToggle is jquery's expander. 
   * .. allows a click to cause an element to expand
   * .. this allows an extra callback function and speed vars
   */
  addSlideToggleListener: function( toClick, toSlide, andDoFn, speed ) {
    toClick.click(function(){
      andDoFn();
      toSlide.slideToggle(speed);
    });
  },

  /*
   * Positioning of Elements
   * BERGEN: Currently this is only being used by the nav, why not put this in mb_nav?
   */

  /* Distance from top of document */
  distanceFromTop: function ( element ) { 
    return $(element).offset().top;
  },
  
  /* Distance from top of closest positioned parent */
  distanceFromTopOfContainer: function ( element ) { 
    return $(element).position().top;
  },

  /*
   * Query String retrieval 
   */
  getParam: function(p){
    var queryParams = mb_utils._getQueryParams();
    return queryParams[p]
  },

  _getQueryParams: function() {
    qs = document.location.search
    qs = qs.split("+").join(" ");

    var params = {}, tokens,
        re = /[?&]?([^=]+)=([^&]*)/g;

    while (tokens = re.exec(qs)) {
      params[decodeURIComponent(tokens[1]).toString()]
          = decodeURIComponent(tokens[2]);
    }

    return params;
  },
  
}

/* ----- end mb_utils ----- */

/* ----- Check for Mobile ----- */

var isMobile = {
  Android: function() {
    return navigator.userAgent.match(/Android/i);
  },
  BlackBerry: function() {
    return navigator.userAgent.match(/BlackBerry/i);
  },
  iOS: function() {
    return navigator.userAgent.match(/iPhone|iPad|iPod/i);
  },
  iPad: function() {
    return navigator.userAgent.match(/iPad/i);
  },
  Opera: function() {
    return navigator.userAgent.match(/Opera Mini/i);
  },
  Windows: function() {
    return navigator.userAgent.match(/IEMobile/i);
  },
  any: function() {
    //console.log("w:" +screen.width + "ua:" + navigator.userAgent + ", isIpad:" + isMobile.iPad());
    return (screen.width <= 500) || ( isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
  }

};

/* ----- end Check for Mobile ----- */

