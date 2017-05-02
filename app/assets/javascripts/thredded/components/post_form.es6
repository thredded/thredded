//= require ./preview_area

(($, autosize) => {
  const COMPONENT_SELECTOR = '[data-thredded-post-form]';

  class ThreddedPostForm {
    constructor() {
      this.textareaSelector = 'textarea';
    }

    init($nodes) {
      let $textarea = $nodes.find(this.textareaSelector);
      this.autosize($textarea);
      $nodes.each(function() {
        new ThreddedPreviewArea($(this));
      });
      new ThreddedMentionAutocompletion($).init($nodes);
    }

    autosize($textarea) {
      autosize($textarea)
    }

    destroy($nodes) {
      autosize.destroy($nodes.find(this.textareaSelector));
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
})(jQuery, window.autosize);
