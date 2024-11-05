# frozen_string_literal: true

module Thredded
  module Compat
    class << self
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
