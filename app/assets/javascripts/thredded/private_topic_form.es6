class ThreddedPrivateTopicForm {
  constructor() {
    this.titleSelector = '#private_topic_title';
    this.formSelector = '.private-topic-form';
    this.compactSelector = this.formSelector + '.is-compact';
    this.expandedSelector = this.formSelector + '.is-expanded';
    this.escapeElements = 'input, textarea';
    this.escapeKeyCode = 27;
  }

  init() {
    jQuery('#private_topic_user_ids').chosen();
    jQuery(this.formSelector).
      on('focus', this.titleSelector, e => {
        jQuery(e.target).closest(this.compactSelector).toggleClass('is-compact is-expanded');
      }).
      on('keydown', this.escapeElements, e => {
        if (e.keyCode == this.escapeKeyCode) {
          jQuery(this.expandedSelector).toggleClass('is-compact is-expanded');
          e.target.blur();
        }
      });
  }
}


