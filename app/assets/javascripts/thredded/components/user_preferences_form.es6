(function($) {
  const COMPONENT_SELECTOR = '[data-thredded-user-preferences-form]';
  const NOTIFY_ON_MENTION_SELECTOR = ':checkbox[name="user_preferences_form[notify_on_mention]"]';
  const MESSAGEBOARD_NOTIFY_ON_MENTION_SELECTOR = '[name="user_preferences_form[messageboard_notify_on_mention]"]';

  class UserPreferencesForm {
    constructor(form) {
      this.$form = $(form);
      this.$notifyOnMention = this.$form.find(NOTIFY_ON_MENTION_SELECTOR);
      this.$messageboardNotifyOnMention = this.$form.find(MESSAGEBOARD_NOTIFY_ON_MENTION_SELECTOR);

      this.messageboardNotifyOnMentionCheckedWas = this.$messageboardNotifyOnMention.prop('checked');
      this.$messageboardNotifyOnMention.on('change', () => {
        this.rememberMessageboardNotifyOnMentionChecked();
      });
      this.rememberMessageboardNotifyOnMentionChecked();

      this.$notifyOnMention.on('change', () => {
        this.updateMessageboardNotifyOnMention();
      });
      this.updateMessageboardNotifyOnMention();
    }

    rememberMessageboardNotifyOnMentionChecked() {
      this.messageboardNotifyOnMentionCheckedWas =
        this.$messageboardNotifyOnMention.filter(':checkbox').prop('checked');
    }

    updateMessageboardNotifyOnMention() {
      const enabled = this.$notifyOnMention.prop('checked');
      this.$messageboardNotifyOnMention
        .prop('disabled', !enabled)
        .filter(':checkbox').prop('checked', enabled ? this.messageboardNotifyOnMentionCheckedWas : false);
    }
  }

  $(function() {
    const $forms = $(COMPONENT_SELECTOR);
    if ($forms.length) {
      $forms.each(function() {
        new UserPreferencesForm(this);
      });
    }
  });
})(jQuery);
