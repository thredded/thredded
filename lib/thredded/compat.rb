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
    end
  end
end
