# frozen_string_literal: true
module Thredded
  class UserPreferencesForm
    include ActiveModel::Model

    # @return [Thredded::Messageboard, nil]
    attr_reader :messageboard

    validate :validate_children

    delegate :follow_topics_on_mention, :follow_topics_on_mention=,
             :notify_on_message, :notify_on_message=,
             :followed_topic_emails, :followed_topic_emails=,
             to: :user_preference

    delegate :follow_topics_on_mention, :follow_topics_on_mention=,
             :followed_topic_emails, :followed_topic_emails=,
             to: :user_messageboard_preference,
             prefix: :messageboard

    # @param user [Thredded.user_class]
    # @param messageboard [Thredded::Messageboard, nil]
    def initialize(user:, messageboard: nil, params: {})
      @user = user
      @messageboard = messageboard
      super(params)
    end

    # @return [Boolean]
    def save
      return false unless valid?
      Thredded::UserPreference.transaction do
        user_preference.save!
        user_messageboard_preference.save! if messageboard
      end
      true
    end

    private

    # @return [Thredded::UserPreference]
    def user_preference
      @user_preference ||= @user.thredded_user_preference
    end

    # @return [Thredded::UserMessageboardPreference, nil]
    def user_messageboard_preference
      return nil unless @messageboard
      @user_messageboard_preference ||=
        user_preference.messageboard_preferences.find_or_initialize_by(messageboard_id: @messageboard.id)
    end

    def validate_children
      promote_errors(user_preference.errors) if user_preference.invalid?
      if messageboard && user_messageboard_preference.invalid?
        promote_errors(user_messageboard_preference.errors, :messageboard)
      end
    end

    def promote_errors(child_errors, prefix = nil)
      child_errors.each do |attribute, message|
        errors.add([prefix, attribute].compact.join('_'), message)
      end
    end
  end
end
