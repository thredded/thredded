require 'support/features/page_object/base'

module PageObject
  class Messageboards < Base
    def visit_index_as(user)
      signs_in_as(user.to_s)
      visit root_path
    end

    def visit_index
      visit root_path
    end

    def include?(messageboard)
      all('a', text: messageboard.name).any?
    end
  end
end
