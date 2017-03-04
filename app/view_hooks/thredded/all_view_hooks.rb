# frozen_string_literal: true
module Thredded
  class AllViewHooks
    # @return [PostCommon]
    attr_reader :post_common
    # @return [PostsCommon]
    attr_reader :posts_common
    # @return [PostForm]
    attr_reader :post_form
    # @return [MessageboardsIndex]
    attr_reader :messageboards_index
    # @return [ModerationUserPage]
    attr_reader :moderation_user_page

    @instance = nil
    class << self
      # @return [Thredded::AllViewHooks]
      attr_reader :instance

      # Called when the class is reloaded so that server restart is not required
      # when changing view hooks in development.
      def reset_instance!
        @instance = Thredded::AllViewHooks.new
      end
    end

    def initialize
      @post_common = PostCommon.new
      @posts_common = PostsCommon.new
      @post_form = PostForm.new
      @moderation_user_page = ModerationUserPage.new
      @messageboards_index = MessageboardsIndex.new
    end

    # View hooks for collections of public or private posts.
    class PostsCommon
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :pagination_top
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :pagination_bottom

      def initialize
        @pagination_top = ViewHook.new
        @pagination_bottom = ViewHook.new
      end
    end

    class PostCommon
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :actions
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :mark_as_unread

      def initialize
        @actions = ViewHook.new
        @mark_as_unread = ViewHook.new
      end
    end

    class PostForm
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :content_text_area

      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :preview_area

      def initialize
        @content_text_area = ViewHook.new
        @preview_area = ViewHook.new
      end
    end

    class MessageboardsIndex
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :container
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :list
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :group
      # @return [Thredded::AllViewHooks::ViewHook]
      attr_reader :messageboard

      def initialize
        @container = ViewHook.new
        @list = ViewHook.new
        @group = ViewHook.new
        @messageboard = ViewHook.new
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
      def render(view_context, **args, &block)
        Thredded::ViewHooks::Renderer.new(view_context, @config).render(**args, &block)
      end
    end
  end
end
