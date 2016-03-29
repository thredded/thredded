module Thredded
  class BaseTopicDecorator < SimpleDelegator
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def slug
      __getobj__.slug.nil? ? id : __getobj__.slug
    end

    def original
      __getobj__
    end
  end
end
