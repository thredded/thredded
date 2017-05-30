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
require 'thredded/html_pipeline/at_mention_filter'
require 'thredded/html_pipeline/autolink_filter'
require 'thredded/html_pipeline/kramdown_filter'
require 'thredded/html_pipeline/onebox_filter'
require 'thredded/html_pipeline/wrap_iframes_filter'

# Asset compilation
require 'autoprefixer-rails'
require 'jquery/rails'
require 'timeago_js'
require 'select2-rails'
require 'sprockets/es6'

require 'thredded/version'
require 'thredded/engine'
require 'thredded/errors'

require 'thredded/view_hooks/config'
require 'thredded/view_hooks/renderer'

# Require these explicitly so that they do not need to be required if used in the initializer:
require 'thredded/content_formatter'
require 'thredded/email_transformer'

require 'thredded/collection_to_strings_with_cache_renderer'

module Thredded
  mattr_accessor \
    :autocomplete_min_length,
    :active_user_threshold,
    :avatar_url,
    :email_from,
    :email_outgoing_prefix,
    :layout,
    :messageboards_order,
    :routes_id_constraint,
    :user_display_name_method,
    :user_name_column,
    :user_path

  # @return [Symbol] The name of the method used by Thredded controllers and views to fetch the currently signed-in user
  mattr_accessor :current_user_method

  # @return [Symbol] The name of the moderator flag column on the users table for the default permissions model
  mattr_accessor :moderator_column

  # @return [Symbol] The name of the admin flag column on the users table for the default permissions model
  mattr_accessor :admin_column

  # @return [Boolean] Whether posts that are pending moderation are visible to regular users.
  mattr_accessor :content_visible_while_pending_moderation

  # @return [Array] The notifiers, by default just the EmailNotifier
  mattr_accessor :notifiers

  # @return [Boolean] Whether users that are following a topic are listed on topic page.
  mattr_accessor :show_topic_followers

  # @return [Symbol] The name of the method used by Thredded to display users
  mattr_accessor :user_display_name_method

  # @return [String] The name of the parent mailer class for Thredded mailers.
  mattr_accessor :parent_mailer
  self.parent_mailer = 'ActionMailer::Base'

  # @return [Proc] The proc that Thredded uses to generate URL slugs from text.
  mattr_accessor :slugifier
  self.slugifier = ->(input) { input.parameterize }

  # @return [Boolean] Whether the user should get subscribed to a new topic they've created.
  mattr_accessor :auto_follow_when_creating_topic
  self.auto_follow_when_creating_topic = true

  # @return [Boolean] Whether the user should get subscribed to a topic after posting in it.
  mattr_accessor :auto_follow_when_posting_in_topic
  self.auto_follow_when_posting_in_topic = true

  # @return [String] The name of the user class
  mattr_reader :user_class_name

  self.active_user_threshold = 5.minutes
  self.admin_column = :admin
  self.avatar_url = ->(user) { Gravatar.src(user.email, 128, 'mm') }
  self.layout = 'thredded/application'
  self.moderator_column = :admin
  self.user_name_column = :name
  self.content_visible_while_pending_moderation = true
  self.show_topic_followers = false
  self.messageboards_order = :position
  self.autocomplete_min_length = 2
  self.routes_id_constraint = /[1-9]\d*/

  # @return [Thredded::AllViewHooks] View hooks configuration.
  def self.view_hooks
    instance = Thredded::AllViewHooks.instance
    unless instance
      fail '`Thredded.view_hooks` must be configured in a `Rails.application.config.to_prepare` block!'
    end
    instance
  end

  def self.notifiers
    @@notifiers ||= [Thredded::EmailNotifier.new] # rubocop:disable Style/ClassVars
  end

  def self.notifiers=(notifiers)
    notifiers.each { |notifier| BaseNotifier.validate_notifier(notifier) }
    @@notifiers = notifiers # rubocop:disable Style/ClassVars
  end

  def self.user_display_name_method
    @@user_display_name_method || user_name_column
  end

  # @param value [:position, :topics_count_desc, :last_post_at_desc]
  def self.messageboards_order=(value)
    case value
    when :position, :topics_count_desc, :last_post_at_desc
      @@messageboards_order = value # rubocop:disable Style/ClassVars
    else
      fail ArgumentError, "Unexpected value for Thredded.messageboards_order: #{value}"
    end
  end

  # @param user_class_name [String]
  def self.user_class=(user_class_name)
    unless user_class_name.is_a?(String)
      fail "Thredded.user_class must be set to a String, got #{user_class_name.inspect}"
    end
    @@user_class_name = user_class_name # rubocop:disable Style/ClassVars
  end

  # @return [Class<Thredded::UserExtender>] the user class from the host application.
  def self.user_class
    # This is nil before the initializer is installed.
    return nil if @@user_class_name.nil?
    @@user_class_name.constantize
  end

  # @param view_context [Object] context to execute the lambda in.
  # @param user [Thredded.user_class]
  # @return [String] path to the user evaluated in the specified context.
  def self.user_path(view_context, user)
    view_context.instance_exec(user, &@@user_path)
  end

  # Whether the layout is a thredded layout as opposed to the application layout.
  def self.standalone_layout?
    layout.is_a?(String) && layout.start_with?('thredded/')
  end

  # Returns a view for the given posts' scope, applying read permission filters to the scope.
  # Can be used in main_app, e.g. for showing the recent user posts on the profile page.
  #
  # @param scope [ActiveRecord::Relation<Thredded::Post>] the posts scope for which to return the view.
  # @param current_user [Thredded.user_class, nil] the user viewing the posts.
  # @return [PostsPageView]
  def self.posts_page_view(scope:, current_user:)
    current_user ||= Thredded::NullUser.new
    PostsPageView.new(
      current_user,
      Pundit.policy_scope!(current_user, scope)
        .where(messageboard_id: Pundit.policy_scope!(current_user, Thredded::Messageboard.all).pluck(:id))
        .includes(:postable)
    )
  end

  # @api private
  def self.rails_gte_51?
    @rails_gte_51 = (Rails.gem_version >= Gem::Version.new('5.1.0')) if @rails_gte_51.nil?
    @rails_gte_51
  end
end
