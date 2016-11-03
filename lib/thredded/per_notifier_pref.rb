# frozen_string_literal: true
module Thredded
  # in this class we dynamically set up an accessor for all the Thredded.notifiers (by their key)
  # as we don't know in advance what the keys are,
  # we try to not pollute the namespace
  # nonetheless some keys would be bad, so we sanity check those on setup
  class PerNotifierPref
    attr_reader :_hash

    def initialize(values = {})
      self.class.ensure_notifiers
      @_hash = Hash.new(true)
      if values.is_a?(PerNotifierPref)
        @_hash.merge!(values._hash)
      else
        values.each { |k, value| self[k] = value }
      end
    end

    def []=(k, v)
      @_hash[k.to_s] = _type_cast(v)
    end

    def [](k)
      @_hash[k.to_s]
    end

    def self.notifier_keys
      @@notifier_keys ||= Thredded.notifiers.map do |notifier| # rubocop:disable Style/ClassVars
        PerNotifierPref.class_eval <<-METHODS
          def #{notifier.key}=(value)
            @_hash['#{notifier.key}'] = value
          end
          def #{notifier.key}
            @_hash['#{notifier.key}']
          end
        METHODS
        notifier.key
      end
    end

    def self.ensure_notifiers
      PerNotifierPref.notifier_keys
    end

    # serialization

    class << self
      def dump(instance)
        return '' if blank?
        fail "Should be #{name} but was a #{instance.class.name}" unless instance.is_a?(PerNotifierPref)
        instance._dump
      end

      def load(s)
        return nil if s.nil?
        new.tap { |instance| instance._load(s) }
      end
    end

    FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].to_set
    TERM_SEPARATOR ||= ','
    VALUE_SEPARATOR ||= ':'

    def _dump
      @_hash.map { |k, v| _dump_notifier_to_string(k, v) }.join(TERM_SEPARATOR)
    end

    def _dump_notifier_to_string(k, v)
      "#{k}#{VALUE_SEPARATOR}#{v ? 'true' : 'false'}"
    end

    def _load(s)
      s.split(TERM_SEPARATOR).each { |t| _load_notifier_from_string(t) }
    end

    def _load_notifier_from_string(s)
      k, v = s.split(VALUE_SEPARATOR)
      self[k] = v
    end

    def _type_cast(value)
      FALSE_VALUES.include?(value) ? false : value
    end

    class NotificationsForPrivateTopics < PerNotifierPref
      def model_name
        ActiveModel::Name.new(self.class, nil, 'NotificationsForPrivateTopics')
      end
    end
    class NotificationsForFollowedTopics < PerNotifierPref
      def model_name
        ActiveModel::Name.new(self.class, nil, 'NotificationsForFollowedTopics')
      end
    end
    class MessageboardNotificationsForFollowedTopics < PerNotifierPref
      def model_name
        ActiveModel::Name.new(self.class, nil, 'MessageboardNotificationsForFollowedTopics')
      end
    end
  end
end
