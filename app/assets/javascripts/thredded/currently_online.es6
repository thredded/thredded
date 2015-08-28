(function($) {
  const COMPONENT_SELECTOR = '[data-thredded-currently-online]';

  class ThreddedCurrentlyOnline {
    init($nodes) {
      $($nodes).
        on('mouseenter', function(e) {
          $(this).addClass('is-expanded');
        }).
        on('mouseleave', function(e) {
          $(this).removeClass('is-expanded');
        }).
        on('touchstart', function(e) {
          $(this).toggleClass('is-expanded');
        });
    }
  }

  $(function() {
    var $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedCurrentlyOnline().init($nodes);
    }
  });
})(jQuery);
