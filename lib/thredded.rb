require 'thredded/engine'
require 'cancan'
require 'carrierwave'
require 'kaminari'
require 'friendly_id'
require 'thredded/filter/base'
require 'thredded/filter/at_notification'
require 'thredded/filter/attachment'
require 'thredded/filter/bbcode'
require 'thredded/filter/emoji'
require 'thredded/filter/markdown'
require 'thredded/filter/syntax'
require 'thredded/filter/textile'

module Thredded
  mattr_accessor :user_class

  def self.user_class
    if @@user_class.is_a?(Class)
      raise 'Please use a string instead of a class'
    end

    if @@user_class.is_a?(String)
      begin
        Object.const_get(@@user_class)
      rescue NameError
        @@user_class.constantize
      end
    end
  end
end
