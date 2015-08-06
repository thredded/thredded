class ThreddedTopicForm {
  constructor() {
    this.titleSelector = '#topic_title';
    this.formSelector = '.topic-form.is-compact';
    this.expandedSelector = '.topic-form.is-expanded';
    this.escapeElements = '.topic-form input, .topic-form textarea';
  }

  init() {
    var _self = this;

    jQuery(this.titleSelector).on('focus', e => {
      jQuery(_self.formSelector).get(0).className = 'topic-form is-expanded';
    })

    jQuery(_self.escapeElements).keydown(function(e) {
      let escapeKeyCode = 27

      if(e.keyCode == escapeKeyCode) {
        jQuery(_self.expandedSelector).get(0).className = 'topic-form is-compact';
        jQuery(_self.escapeElements).blur();
      }
    });
  }
}

