class ThreddedTopicForm {
  constructor() {
    this.titleSelector = '#topic_title';
    this.formSelector = '.topic-form';
  }

  init() {
    var _self = this;

    jQuery(this.titleSelector).on('focus', e => {
      jQuery(_self.formSelector).get(0).className = 'topic-form is-expanded';
    })
  }
}

