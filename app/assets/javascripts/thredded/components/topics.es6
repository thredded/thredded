(function($) {
  const COMPONENT_SELECTOR = '[data-thredded-topics]';

  const TOPIC_SELECTOR = 'article';
  const TOPIC_LINK_SELECTOR = 'h1 a';
  const TOPIC_UNREAD_CLASS = 'thredded--topic--unread';
  const TOPIC_READ_CLASS = 'thredded--topic--read';

  class ThreddedTopics {
    init($nodes) {
      $nodes.on('click', TOPIC_LINK_SELECTOR, (evt) => {
        $(evt.target).closest(TOPIC_SELECTOR).addClass(TOPIC_READ_CLASS).removeClass(TOPIC_UNREAD_CLASS);
      });
    }
  }

  $(function() {
    var $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedTopics().init($nodes);
    }
  });
})(jQuery);
