(($) => {
  const COMPONENT_SELECTOR = '[data-thredded-user-preferences-form]';
  const FOLLOW_TOPICS_ON_MENTION_SELECTOR = ':checkbox[name="user_preferences_form[follow_topics_on_mention]"]';
  const MESSAGEBOARD_FOLLOW_TOPICS_ON_MENTION_SELECTOR = '[name="user_preferences_form[messageboard_follow_topics_on_mention]"]';
  const FOLLOWED_TOPIC_EMAILS_SELECTOR = ':checkbox[name="user_preferences_form[followed_topic_emails]"]';
  const MESSAGEBOARD_FOLLOWED_TOPIC_EMAILS_SELECTOR = ':checkbox[name="user_preferences_form[messageboard_followed_topic_emails]"]';

  class UserPreferencesForm {
    constructor(form) {
      this.$form = $(form);
      this.$followTopicsOnMention = this.$form.find(FOLLOW_TOPICS_ON_MENTION_SELECTOR);
      this.$messageboardFollowTopicsOnMention = this.$form.find(MESSAGEBOARD_FOLLOW_TOPICS_ON_MENTION_SELECTOR);
      this.$followedTopicEmails = this.$form.find(FOLLOWED_TOPIC_EMAILS_SELECTOR);
      this.$messageboardFollowedTopicEmails = this.$form.find(MESSAGEBOARD_FOLLOWED_TOPIC_EMAILS_SELECTOR);

      this.messageboardFollowTopicsOnMentionCheckedWas = this.$messageboardFollowTopicsOnMention.prop('checked');
      this.$messageboardFollowTopicsOnMention.on('change', () => {
        this.rememberMessageboardAutofollowTopicsChecked();
      });
      this.rememberMessageboardAutofollowTopicsChecked();

      this.$followTopicsOnMention.on('change', () => {
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
      this.messageboardFollowTopicsOnMentionCheckedWas =
        this.$messageboardFollowTopicsOnMention.filter(':checkbox').prop('checked');
    }

    updateMessageboardAutofollowTopics() {
      const enabled = this.$followTopicsOnMention.prop('checked');
      this.$messageboardFollowTopicsOnMention
        .prop('disabled', !enabled)
        .filter(':checkbox').prop('checked', enabled ? this.messageboardFollowTopicsOnMentionCheckedWas : false);
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

  window.Thredded.onPageLoad(() => {
    const $forms = $(COMPONENT_SELECTOR);
    if ($forms.length) {
      $forms.each(function() {
        new UserPreferencesForm(this);
      });
    }
  });
})(jQuery);
