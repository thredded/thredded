# frozen_string_literal: true

# Backend
require 'pundit'
require 'active_record_union'
require 'db_text_search'
require 'friendly_id'
require 'html/pipeline'
require 'html/pipeline/sanitization_filter'
require 'rinku'
require 'kaminari'
require 'rb-gravatar'
require 'active_job'
require 'inline_svg'

# Require these explictly to make sure they are not reloaded.
# This allows for configuring them by accessing class methods in the initializer.
require 'thredded/formatting_demo_content'
require 'thredded/html_pipeline/utils'
require 'thredded/html_pipeline/at_mention_filter'
require 'thredded/html_pipeline/autolink_filter'
require 'thredded/html_pipeline/kramdown_filter'
require 'thredded/html_pipeline/onebox_filter'
require 'thredded/html_pipeline/wrap_iframes_filter'
require 'thredded/html_pipeline/spoiler_tag_filter'

# Asset compilation
require 'autoprefixer-rails'
require 'timeago_js'
require 'sprockets/es6'

require 'thredded/version'
require 'thredded/engine'
require 'thredded/errors'

require 'thredded/view_hooks/config'
require 'thredded/view_hooks/renderer'

# Require these explicitly so that they do not need to be required if used in the initializer:
require 'thredded/content_formatter'
require 'thredded/email_transformer'
require 'thredded/base_notifier'

require 'thredded/arel_compat'
require 'thredded/collection_to_strings_with_cache_renderer'

module Thredded
  class << self
    attr_accessor \
      :autocomplete_min_length,
      :active_user_threshold,
      :avatar_url,
      :email_from,
      :email_outgoing_prefix,
      :layout,
      :messageboards_order,
      :routes_id_constraint,
      :user_name_column

    # A lambda that generates a URL path to the user page for the given user.
    attr_writer :user_path

    # @return [Symbol] The name of the method used by Thredded controllers and views to get the currently signed-in user
    attr_accessor :current_user_method

    # @return [Symbol] The name of the moderator flag column on the users table for the default permissions model
    attr_accessor :moderator_column

    # @return [Symbol] The name of the admin flag column on the users table for the default permissions model
    attr_accessor :admin_column

    # @return [Boolean] Whether posts that are pending moderation are visible to regular users.
    attr_accessor :content_visible_while_pending_moderation

    # @return [Boolean] Whether users that are following a topic are listed on the topic page.
    attr_accessor :show_topic_followers

    # @return [Symbol] The name of the method used by Thredded to display users
    attr_writer :user_display_name_method

    # @return [String] The name of the parent mailer class for Thredded mailers.
    attr_accessor :parent_mailer

    # @return [Proc] The proc that Thredded uses to generate URL slugs from text.
    attr_accessor :slugifier

    # @return [Boolean] Whether the user should get subscribed to a new topic they've created.
    attr_accessor :auto_follow_when_creating_topic

    # @return [Boolean] Whether the user should get subscribed to a topic after posting in it.
    attr_accessor :auto_follow_when_posting_in_topic

    # @return [String] The name of the user class
    attr_reader :user_class_name

    # @return [Range<Integer>] The range of valid topic title lengths.
    attr_accessor :topic_title_length_range

    # @return [Boolean] Whether the list of users who are currently online is displayed.
    attr_accessor :currently_online_enabled

    # @return [Boolean] Whether the private messaging functionality is enabled.
    attr_accessor :private_messaging_enabled

    # @return [Thredded::AllViewHooks] View hooks configuration.
    def view_hooks
      instance = Thredded::AllViewHooks.instance
      unless instance
        fail '`Thredded.view_hooks` must be configured in a `Rails.application.config.to_prepare` block!'
      end
      instance
    end

    # @return [Array] The notifiers, by default just the EmailNotifier
    def notifiers
      @notifiers ||= [Thredded::EmailNotifier.new]
    end

    # @param [Array] notifiers
    def notifiers=(notifiers)
      notifiers.each { |notifier| BaseNotifier.validate_notifier(notifier) }
      @notifiers = notifiers
    end

    # @return [Symbol] The name of the method used by Thredded to display users
    def user_display_name_method
      @user_display_name_method || user_name_column
    end

    # @param value [:position, :topics_count_desc, :last_post_at_desc]
    def messageboards_order=(value)
      case value
      when :position, :topics_count_desc, :last_post_at_desc
        @messageboards_order = value
      else
        fail ArgumentError, "Unexpected value for Thredded.messageboards_order: #{value}"
      end
    end

    # @param user_class_name [String]
    def user_class=(user_class_name)
      unless user_class_name.is_a?(String)
        fail "Thredded.user_class must be set to a String, got #{user_class_name.inspect}"
      end
      @user_class_name = user_class_name
    end

    # @return [Class<Thredded::UserExtender>] the user class from the host application.
    def user_class
      # This is nil before the initializer is installed.
      return nil if @user_class_name.nil?
      @user_class_name.constantize
    end

    # @param view_context [Object] context to execute the lambda in.
    # @param user [Thredded.user_class]
    # @return [String] path to the user evaluated in the specified context.
    def user_path(view_context, user)
      view_context.instance_exec(user, &@user_path)
    end

    # Whether the layout is a thredded layout as opposed to the application layout.
    def standalone_layout?
      layout.is_a?(String) && layout.start_with?('thredded/')
    end

    # Returns a view for the given posts' scope, applying read permission filters to the scope.
    # Can be used in main_app, e.g. for showing the recent user posts on the profile page.
    #
    # @param scope [ActiveRecord::Relation<Thredded::Post>] the posts scope for which to return the view.
    # @param current_user [Thredded.user_class, nil] the user viewing the posts.
    # @return [PostsPageView]
    def posts_page_view(scope:, current_user:)
      current_user ||= Thredded::NullUser.new
      PostsPageView.new(
        current_user,
        Pundit.policy_scope!(current_user, scope)
          .where(messageboard_id: Pundit.policy_scope!(current_user, Thredded::Messageboard.all).pluck(:id))
          .includes(:postable)
      )
    end

    # @api private
    def rails_gte_51?
      @rails_gte_51 = (Rails.gem_version >= Gem::Version.new('5.1.0')) if @rails_gte_51.nil?
      @rails_gte_51
    end
  end

  self.active_user_threshold = 5.minutes
  self.admin_column = :admin
  self.auto_follow_when_creating_topic = true
  self.auto_follow_when_posting_in_topic = true
  self.autocomplete_min_length = 2
  self.avatar_url = ->(user) { Gravatar.src(user.email, 156, 'mm') }
  self.content_visible_while_pending_moderation = true
  self.layout = 'thredded/application'
  self.messageboards_order = :position
  self.moderator_column = :admin
  self.parent_mailer = 'ActionMailer::Base'
  self.routes_id_constraint = /[1-9]\d*/
  self.show_topic_followers = false
  self.slugifier = ->(input) { input.parameterize }
  self.topic_title_length_range = (1..200)
  self.user_name_column = :name
  self.private_messaging_enabled = true
  self.currently_online_enabled = true
end
