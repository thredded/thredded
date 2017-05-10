# frozen_string_literal: true

module Thredded
  module ViewHooks
    class Config
      def initialize
        # @type Array<Proc>
        @before = []
        # @type Array<Proc>
        @replace = []
        # @type Array<Proc>
        @after = []
      end

      # @param [Proc] block
      # @return [Array<Proc>]
      def before(&block)
        @before << block if block
        @before
      end

      # @param [Proc] block
      # @return [Array<Proc>]
      def replace(&block)
        @replace << block if block
        @replace
      end

      # @param [Proc] block
      # @return [Array<Proc>]
      def after(&block)
        @after << block if block
        @after
      end
    end
  end
end
