# frozen_string_literal: true
require_dependency 'thredded/view_hooks/config'
require_dependency 'thredded/view_hooks/renderer'

module Thredded
  module AllViewHooks
    class Config
      # @return [PostForm]
      attr_reader :post_form
      # @return [ModerationUserPage]
      attr_reader :moderation_user_page

      def initialize
        @post_form = PostForm.new
        @moderation_user_page = ModerationUserPage.new
      end

      class PostForm
        # @return [Thredded::ViewHooks::Config]
        attr_reader :content_text_area

        def initialize
          @content_text_area = ViewHooks::Config.new
        end
      end

      class ModerationUserPage
        # @return [Thredded::ViewHooks::Config]
        attr_reader :user_title
        # @return [Thredded::ViewHooks::Config]
        attr_reader :user_info
        # @return [Thredded::ViewHooks::Config]
        attr_reader :user_moderation_actions

        def initialize
          @user_title = ViewHooks::Config.new
          @user_info = ViewHooks::Config.new
          @user_moderation_actions = ViewHooks::Config.new
        end
      end
    end

    class Renderer
      # @return [PostForm]
      attr_reader :post_form
      # @return [ModerationUserPage]
      attr_reader :moderation_user_page

      # @param config [Thredded::AllViewHooks::Config]
      def initialize(view_context, config: Thredded.view_hooks)
        @post_form = PostForm.new(view_context, config.post_form)
        @moderation_user_page = ModerationUserPage.new(view_context, config.moderation_user_page)
      end

      class PostForm
        # @param config [Thredded::AllViewHooks::Config::PostForm]
        def initialize(view_context, config)
          @content_text_area = Thredded::ViewHooks::Renderer.new(view_context, config.content_text_area)
        end

        def content_text_area(&block)
          @content_text_area.render(&block)
        end
      end

      class ModerationUserPage
        # @param config [Thredded::AllViewHooks::Config::ModerationUserPage]
        def initialize(view_context, config)
          @user_title = Thredded::ViewHooks::Renderer.new(view_context, config.user_title)
          @user_info = Thredded::ViewHooks::Renderer.new(view_context, config.user_info)
          @user_moderation_actions = Thredded::ViewHooks::Renderer.new(view_context, config.user_moderation_actions)
        end

        def user_title(&block)
          @user_title.render(&block)
        end

        def user_info(&block)
          @user_info.render(&block)
        end

        def user_moderation_actions(&block)
          @user_moderation_actions.render(&block)
        end
      end
    end
  end
end
