# frozen_string_literal: true

module Thredded
  module Compat
    class << self
      # @api private
      def rails_gte_71?
        @rails_gte_71 = (Rails.gem_version >= Gem::Version.new('7.1.0')) if @rails_gte_71.nil?
        @rails_gte_71
      end

      # @api private
      def rails_gte_72?
        @rails_gte_72 = (Rails.gem_version >= Gem::Version.new('7.2.0')) if @rails_gte_72.nil?
        @rails_gte_72
      end

      # @api private
      # TODO: inline this or put it somewhere else as it's no longer specific to a rails version
      def association_preloader(records:, associations:, scope:)
        ActiveRecord::Associations::Preloader.new(
          records: records, associations: associations, scope: scope
        ).call
      end
    end
  end
end
