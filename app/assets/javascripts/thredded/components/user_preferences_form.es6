(($) => {
  const COMPONENT_SELECTOR = '[data-thredded-user-preferences-form]';
  const BOUND_MESSAGEBOARD_NAME = 'data-thredded-bound-messageboard-pref';

  class MessageboardPreferenceBinding {
    constructor($form, genericCheckboxName, messageboardCheckboxName) {
      this.$genericCheckbox = $form.find(`:checkbox[name="${genericCheckboxName}"]`);
      this.$messageboardCheckbox = $form.find(`:checkbox[name="${messageboardCheckboxName}"]`);
      this.$messageboardCheckbox.on('change', () => {
        this.rememberMessageboardChecked();
      });
      this.rememberMessageboardChecked();
      this.$genericCheckbox.on('change', () => {
        this.updateMessageboardCheckbox();
      });
      this.updateMessageboardCheckbox();
    }

    rememberMessageboardChecked() {
      this.messageboardCheckedWas = this.$messageboardCheckbox.filter(':checkbox').prop('checked');
    }

    updateMessageboardCheckbox() {
      const enabled = this.$genericCheckbox.prop('checked');
      this.$messageboardCheckbox
        .prop('disabled', !enabled)
        .filter(':checkbox').prop('checked', enabled ? this.messageboardCheckedWas : false);
    }

  }
  class UserPreferencesForm {
    constructor(form) {
      const $form = $(form);
      $form.find(`input[${BOUND_MESSAGEBOARD_NAME}]`).each((index, element) => {
        let $elem = $(element);
        new MessageboardPreferenceBinding($form, $elem.attr('name'), $elem.attr(BOUND_MESSAGEBOARD_NAME));
      })
    }
  }

  window.Thredded.onPageLoad(() => {
    const $forms = $(COMPONENT_SELECTOR);
    if ($forms.length) {
      $forms.each(function() {
        new UserPreferencesForm(this);
      });
    }
  });
})(jQuery);
