//= require thredded/core/thredded
//= require thredded/core/on_page_load

// Reflects the logic of user preference settings by enabling/disabling certain inputs.
(() => {
  const Thredded = window.Thredded;

  const COMPONENT_SELECTOR = '[data-thredded-user-preferences-form]';
  const BOUND_MESSAGEBOARD_NAME = 'data-thredded-bound-messageboard-pref';
  const UPDATE_ON_CHANGE_NAME = 'data-thredded-update-checkbox-on-change';

  class MessageboardPreferenceBinding {
    constructor(form, genericCheckboxName, messageboardCheckboxName) {
      this.messageboardCheckbox = form.querySelector(`[type="checkbox"][name="${messageboardCheckboxName}"]`);
      if (!this.messageboardCheckbox) {
        return;
      }
      this.messageboardCheckbox.addEventListener('change', () => {
        this.rememberMessageboardChecked();
      });
      this.rememberMessageboardChecked();

      this.genericCheckbox = form.querySelector(`[type="checkbox"][name="${genericCheckboxName}"]`);
      this.genericCheckbox.addEventListener('change', () => {
        this.updateMessageboardCheckbox();
      });
      this.updateMessageboardCheckbox();
    }

    rememberMessageboardChecked() {
      this.messageboardCheckedWas = this.messageboardCheckbox.checked;
    }

    updateMessageboardCheckbox() {
      const enabled = this.genericCheckbox.checked;
      this.messageboardCheckbox.disabled = !enabled;
      this.messageboardCheckbox.checked = enabled ? this.messageboardCheckedWas : false;
    }
  }

  class UpdateOnChange {
    constructor(form, sourceElement, targetName) {
      const target = form.querySelector(`[type="checkbox"][name="${targetName}"]`);
      if (!target) return;
      sourceElement.addEventListener('change', () => {
        target.checked = sourceElement.checked;
      });
    }
  }

  class UserPreferencesForm {
    constructor(form) {
      Array.prototype.forEach.call(form.querySelectorAll(`input[${BOUND_MESSAGEBOARD_NAME}]`), (element) => {
        new MessageboardPreferenceBinding(form, element.name, element.getAttribute(BOUND_MESSAGEBOARD_NAME));
      });
      Array.prototype.forEach.call(form.querySelectorAll(`input[${UPDATE_ON_CHANGE_NAME}]`), (element) => {
        new UpdateOnChange(form, element, element.getAttribute(UPDATE_ON_CHANGE_NAME));
      });
    }
  }

  Thredded.onPageLoad(() => {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), (form) => {
      new UserPreferencesForm(form);
    });
  });
})();
