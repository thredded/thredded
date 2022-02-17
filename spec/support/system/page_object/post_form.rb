# frozen_string_literal: true

require 'support/system/page_object/base'

module PageObject
  class PostForm < Base
    def content
      find('#post_content')[:value]
    end
  end
end
