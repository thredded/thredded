(function($) {
  const COMPONENT_SELECTOR = '[data-thredded-post-form]';

  class ThreddedPostForm {
    constructor() {
      this.textareaSelector = 'textarea';
    }

    init($nodes) {
      $nodes.find(this.textareaSelector).autosize();
    }
  }

  $(function() {
    var $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedPostForm().init($nodes);
    }
  });
})(jQuery);
