class ThreddedCurrentlyOnline {
  constructor() {
    this.currentlyOnlineSelector = '.currently-online';
  }

  init() {
    jQuery(this.currentlyOnlineSelector).on('mouseenter', function(e) {
      jQuery(this).addClass('is-expanded');
    })

    jQuery(this.currentlyOnlineSelector).on('mouseleave', function(e) {
      jQuery(this).removeClass('is-expanded');
    })

    jQuery(this.currentlyOnlineSelector).on('touchstart', function(e) {
      jQuery(this).toggleClass('is-expanded');
    })
  }
}
