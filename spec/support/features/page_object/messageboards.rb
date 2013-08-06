require 'support/features/page_object/base'

module PageObject
  class Messageboards < Base
    def visit_index_as(user)
      signs_in_as(user.name)
      visit messageboards_path
    end

    def visit_index
      visit messageboards_path
    end

    def include?(messageboard)
      all('a', text: messageboard.name).any?
    end
  end
end
