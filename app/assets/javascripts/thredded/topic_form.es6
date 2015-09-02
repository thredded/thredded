(function($) {
  const COMPONENT_SELECTOR = '[data-thredded-topic-form]';
  class ThreddedTopicForm {
    constructor() {
      this.titleSelector = '[data-thredded-topic-form-title]';
      this.compactSelector = 'form.is-compact';
      this.expandedSelector = 'form.is-expanded';
      this.escapeElements = 'input, textarea';
      this.escapeKeyCode = 27;
    }

    toggleExpanded(child, expanded) {
      jQuery(child).closest(expanded ? this.compactSelector : this.expandedSelector).toggleClass('is-compact is-expanded');
    }

    init($nodes) {
      $nodes.filter(this.compactSelector).
        on('focus', this.titleSelector, e => {
          this.toggleExpanded(e.target, true);
        }).
        on('keydown', this.escapeElements, e => {
          if (e.keyCode == this.escapeKeyCode) {
            this.toggleExpanded(e.target, false);
            e.target.blur();
          }
        }).
        on('blur', this.escapeElements, e => {
          var blurredEl = e.target;
          $(document.body).one('mouseup touchend', e => {
            var $blurredElForm = $(blurredEl).closest('form');
            // Un-expand if the new focus element is outside of the same form and
            // all the input elements are empty.
            if (!$(e.target).closest('form').is($blurredElForm) &&
              $blurredElForm.find(this.escapeElements).is(function() {
                return !this.value;
              })) {
              this.toggleExpanded(blurredEl, false);
            }
          })
        });
    }

  }

  $(function() {
    var $nodes = $(COMPONENT_SELECTOR);
    if ($nodes.length) {
      new ThreddedTopicForm().init($nodes);
    }
  });
})(jQuery);


