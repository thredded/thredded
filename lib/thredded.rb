# Backend
require 'cancan'
require 'db_text_search'
require 'friendly_id'
require 'html/pipeline'
require 'html/pipeline/at_mention_filter'
require 'html/pipeline/bbcode_filter'
require 'kaminari'
require 'rb-gravatar'
require 'active_job'

# Asset compilation
require 'autoprefixer-rails'
require 'autosize/rails'
require 'jquery/rails'
require 'rails-timeago'
require 'select2-rails'
require 'sprockets/es6'

require 'thredded/engine'
require 'thredded/errors'
require 'thredded/messageboard_user_permissions'
require 'thredded/post_user_permissions'
require 'thredded/private_topic_user_permissions'
require 'thredded/topic_user_permissions'
require 'thredded/search_sql_builder'
require 'thredded/main_app_route_delegator'

module Thredded
  mattr_accessor :user_class,
    :user_name_column,
    :avatar_url,
    :email_incoming_host,
    :email_from,
    :email_outgoing_prefix,
    :email_reply_to,
    :user_path,
    :file_storage,
    :asset_root,
    :layout,
    :active_user_threshold

  # @return [Symbol] The name of the moderator flag column on the users table for the default permissions model
  mattr_accessor :moderator_column

  # @return [Symbol] The name of the admin flag column on the users table for the default permissions model
  mattr_accessor :admin_column

  self.user_name_column = :name
  self.avatar_url = ->(user) { Gravatar.src(user.email, 128, 'mm') }
  self.active_user_threshold = 5.minutes
  self.file_storage = :file # or :fog
  self.asset_root = '' # or fully qualified URI to assets
  self.layout = 'thredded/application'
  self.email_reply_to = -> postable { "#{postable.hash_id}@#{Thredded.email_incoming_host}" }
  self.moderator_column = :admin
  self.admin_column = :admin

  # @return [Class<Thredded::UserExtender>] the user class from the host application.
  def self.user_class
    if @@user_class.is_a?(Class)
      fail 'Please use a string instead of a class'
    end

    if @@user_class.is_a?(String)
      begin
        Object.const_get(@@user_class)
      rescue NameError
        @@user_class.constantize
      end
    end
  end

  # @param view_context [Object] context to execute the lambda in.
  # @param user [Thredded.user_class]
  # @return [String] path to the user evaluated in the specified context.
  def self.user_path(view_context, user)
    if @@user_path.respond_to? :call
      view_context.instance_exec(user, &@@user_path)
    else
      '/'
    end
  end

  # Whether the layout is a thredded layout as opposed to the application layout.
  def self.standalone_layout?
    layout.is_a?(String) && layout.start_with?('thredded/')
  end
end
