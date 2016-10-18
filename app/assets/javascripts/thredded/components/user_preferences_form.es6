(function($) {
  const COMPONENT_SELECTOR = '[data-thredded-user-preferences-form]';
  const AUTO_FOLLOW_TOPICS_SELECTOR = ':checkbox[name="user_preferences_form[auto_follow_topics]"]';
  const MESSAGEBOARD_AUTO_FOLLOW_TOPICS_SELECTOR = '[name="user_preferences_form[messageboard_auto_follow_topics]"]';
  const FOLLOWED_TOPIC_EMAILS_SELECTOR = ':checkbox[name="user_preferences_form[followed_topic_emails]"]';
  const MESSAGEBOARD_FOLLOWED_TOPIC_EMAILS_SELECTOR = ':checkbox[name="user_preferences_form[messageboard_followed_topic_emails]"]';

  class UserPreferencesForm {
    constructor(form) {
      this.$form = $(form);
      this.$autofollowTopics = this.$form.find(AUTO_FOLLOW_TOPICS_SELECTOR);
      this.$messageboardAutofollowTopics = this.$form.find(MESSAGEBOARD_AUTO_FOLLOW_TOPICS_SELECTOR);
      this.$followedTopicEmails = this.$form.find(FOLLOWED_TOPIC_EMAILS_SELECTOR);
      this.$messageboardFollowedTopicEmails = this.$form.find(MESSAGEBOARD_FOLLOWED_TOPIC_EMAILS_SELECTOR);

      this.messageboardAutofollowTopicsCheckedWas = this.$messageboardAutofollowTopics.prop('checked');
      this.$messageboardAutofollowTopics.on('change', () => {
        this.rememberMessageboardAutofollowTopicsChecked();
      });
      this.rememberMessageboardAutofollowTopicsChecked();

      this.$autofollowTopics.on('change', () => {
        this.updateMessageboardAutofollowTopics();
      });
      this.updateMessageboardAutofollowTopics();

      this.messageboardFollowedTopicEmailsCheckedWas = this.$messageboardFollowedTopicEmails.prop('checked');
      this.$messageboardFollowedTopicEmails.on('change', () => {
        this.rememberMessageboardFollowedTopicEmailsChecked();
      });
      this.rememberMessageboardFollowedTopicEmailsChecked();

      this.$followedTopicEmails.on('change', () => {
        this.updateMessageboardFollowedTopicEmails();
      });
      this.updateMessageboardFollowedTopicEmails();
    }

    rememberMessageboardAutofollowTopicsChecked() {
      this.messageboardAutofollowTopicsCheckedWas =
        this.$messageboardAutofollowTopics.filter(':checkbox').prop('checked');
    }

    updateMessageboardAutofollowTopics() {
      const enabled = this.$autofollowTopics.prop('checked');
      this.$messageboardAutofollowTopics
        .prop('disabled', !enabled)
        .filter(':checkbox').prop('checked', enabled ? this.messageboardAutofollowTopicsCheckedWas : false);
    }

    rememberMessageboardFollowedTopicEmailsChecked() {
      this.messageboardFollowedTopicEmailsCheckedWas =
        this.$messageboardFollowedTopicEmails.filter(':checkbox').prop('checked');
    }

    updateMessageboardFollowedTopicEmails() {
      const enabled = this.$followedTopicEmails.prop('checked');
      this.$messageboardFollowedTopicEmails
        .prop('disabled', !enabled)
        .filter(':checkbox').prop('checked', enabled ? this.messageboardFollowedTopicEmailsCheckedWas : false);
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
