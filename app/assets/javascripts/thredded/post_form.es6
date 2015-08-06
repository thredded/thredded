class ThreddedPostForm {
  constructor() {
    this.textareaSelector = 'textarea';
  }

  init() {
    jQuery(this.textareaSelector).autosize();
  }
}

