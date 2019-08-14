# frozen_string_literal: true

module PageObject
    class MessageboardGroup
      include Capybara::DSL
      include Thredded::Engine.routes.url_helpers
  
      def initialize(name)
        @name = name
        @group = FactoryBot.create(:messageboard_group, name: @name)
        @mb = FactoryBot.create(:messageboard, group: @group)
      end
  
      def visit_messageboard_group
        visit show_messageboard_group_path(@group)
      end
  
      def name
        @name
      end

      def a_messageboard
        @mb
      end
    end
  end  