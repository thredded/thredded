# Backend
require 'cancan'
require 'friendly_id'
require 'gravtastic'
require 'html/pipeline'
require 'html/pipeline/at_mention_filter'
require 'html/pipeline/bbcode_filter'
require 'kaminari'
require 'q'
require 'threaded_in_memory_queue'

# Asset compilation
require 'bitters'
require 'bourbon'
require 'jquery/rails'
require 'neat'
require 'sprockets/es6'

require 'thredded/engine'
require 'thredded/errors'
require 'thredded/messageboard_user_permissions'
require 'thredded/post_user_permissions'
require 'thredded/private_topic_user_permissions'
require 'thredded/topic_user_permissions'
require 'thredded/search_sql_builder'
require 'thredded/case_insensitive_string_finder'
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
    :queue_backend,
    :queue_memory_log_level,
    :queue_inline

  self.user_name_column = :name
  self.avatar_url = -> (_user, post) { post.gravatar_url(default: 'mm') }
  self.file_storage = :file # or :fog
  self.asset_root = '' # or fully qualified URI to assets
  self.layout = 'thredded/application'
  self.queue_backend = :threaded_in_memory_queue
  self.queue_memory_log_level = Logger::WARN
  self.queue_inline = false
  self.email_reply_to = -> postable { "#{postable.hash_id}@#{Thredded.email_incoming_host}" }

  # @return [Class] the user class from the host application.
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

  def self.use_adapter!(db_adapter)
    TableSqlBuilder.use_adapter! db_adapter
    CaseInsensitiveStringFinder.use_adapter! db_adapter
  end
end
