class ThreddedPrivateTopicForm {
  constructor() {
    this.titleSelector = '#private_topic_title';
    this.formSelector = '.private-topic-form.is-compact';
  }

  init() {
    var _self = this;

    jQuery(this.titleSelector).on('focus', e => {
      jQuery(_self.formSelector).get(0).className = 'private-topic-form is-expanded';
    })

    jQuery('#private_topic_user_ids').chosen();
  }
}


