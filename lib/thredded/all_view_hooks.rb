# frozen_string_literal: true
require_dependency 'thredded/view_hooks/config'
require_dependency 'thredded/view_hooks/renderer'

module Thredded
  class AllViewHooks
    # @return [PostForm]
    attr_reader :post_form
    # @return [ModerationUserPage]
    attr_reader :moderation_user_page

    def initialize
      @post_form = PostForm.new
      @moderation_user_page = ModerationUserPage.new
    end

    def self.current_view_context
      Thread.current[:thredded_view_hooks_current_view_context]
    end

    def self.current_view_context=(value)
      Thread.current[:thredded_view_hooks_current_view_context] = value
    end

    class PostForm
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :content_text_area

      def initialize
        @content_text_area = ViewHook.new
      end
    end

    class ModerationUserPage
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :user_title
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :user_info
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :user_moderation_actions

      def initialize
        @user_title = ViewHook.new
        @user_info = ViewHook.new
        @user_moderation_actions = ViewHook.new
      end
    end

    # Contains the view hook content and can render a view hook.
    class ViewHook
      # @return [Thredded::ViewHooks::Config]
      attr_reader :config

      def initialize
        @config = Thredded::ViewHooks::Config.new
      end

      # @return [String]
      def render(view_context: Thredded::AllViewHooks.current_view_context, &block)
        Thredded::ViewHooks::Renderer.new(view_context, @config).render(&block)
      end
    end
  end
end
