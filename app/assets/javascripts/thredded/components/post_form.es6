(($) => {
  const COMPONENT_SELECTOR = '[data-thredded-post-form]';

  class ThreddedPostForm {
    constructor() {
      this.textareaSelector = 'textarea';
    }

    init($nodes) {
      $nodes.find(this.textareaSelector).autosize();
    }

    destroy($nodes) {
      $nodes.find(this.textareaSelector).trigger('autosize.destroy');
    }
  }

  window.Thredded.onPageLoad(() => {
    const $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedPostForm().init($nodes);
    }
  });

  document.addEventListener('turbolinks:before-cache', () => {
    const $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedPostForm().destroy($nodes);
    }
  });
})(jQuery);
