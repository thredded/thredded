class ThreddedPrivateTopicForm {
  constructor() {
    this.titleSelector = '#private_topic_title';
    this.formSelector = '.private-topic-form.is-compact';
    this.expandedSelector = '.private-topic-form.is-expanded';
    this.escapeElements = '.private-topic-form input, .private-topic-form textarea';
  }

  init() {
    var _self = this;

    jQuery(this.titleSelector).on('focus', e => {
      jQuery(_self.formSelector).get(0).className = 'private-topic-form is-expanded';
    })

    jQuery('#private_topic_user_ids').chosen();

    jQuery(_self.escapeElements).keydown(function(e) {
      let escapeKeyCode = 27

      if(e.keyCode == escapeKeyCode) {
        jQuery(_self.expandedSelector).get(0).className = 'private-topic-form is-compact';
        jQuery(_self.escapeElements).blur();
      }
    });
  }
}


