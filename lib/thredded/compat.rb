# frozen_string_literal: true

module Thredded
  module Compat
    class << self
      # @api private
      def rails_gte_60?
        @rails_gte_60 = (Rails.gem_version >= Gem::Version.new('6.0.0')) if @rails_gte_60.nil?
        @rails_gte_60
      end

      # @api private
      def rails_gte_61?
        @rails_gte_61 = (Rails.gem_version >= Gem::Version.new('6.1.0')) if @rails_gte_61.nil?
        @rails_gte_61
      end

      if Rails.gem_version >= Gem::Version.new('7.0.0')
        # @api private
        def association_preloader(records:, associations:, scope:)
          ActiveRecord::Associations::Preloader.new(
            records: records, associations: associations, scope: scope
          ).call
        end
      else
        # @api private
        def association_preloader(records:, associations:, scope:)
          ActiveRecord::Associations::Preloader.new.preload(
            records, associations, scope
          )
        end
      end
    end
  end
end
