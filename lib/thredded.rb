require 'thredded/engine'
require 'cancan'
require 'carrierwave'
require 'kaminari'
require 'friendly_id'
require 'gravtastic'
require 'q'
require 'threaded_in_memory_queue'
require 'thredded/errors'
require 'html/pipeline'
require 'html/pipeline/bbcode_filter'
require 'html/pipeline/at_mention_filter'
require 'thredded/messageboard_user_permissions'
require 'thredded/post_user_permissions'
require 'thredded/private_topic_user_permissions'
require 'thredded/topic_user_permissions'
require 'thredded/search_sql_builder'
require 'thredded/case_insensitive_string_finder'

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
  self.layout = 'thredded'
  self.queue_backend = :threaded_in_memory_queue
  self.queue_memory_log_level = Logger::WARN
  self.queue_inline = false
  self.email_reply_to = -> postable { "#{postable.hash_id}@#{Thredded.email_incoming_host}" }

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

  def self.user_path(user)
    if @@user_path.respond_to? :call
      @@user_path.call(user)
    else
      '/'
    end
  end

  def self.use_adapter!(db_adapter)
    TableSqlBuilder.use_adapter! db_adapter
    CaseInsensitiveStringFinder.use_adapter! db_adapter
  end
end
