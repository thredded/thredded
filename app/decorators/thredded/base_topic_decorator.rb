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

    private

    def updated_at_str
      updated_at.to_s
    end

    def updated_at_utc
      updated_at.getutc.iso8601
    end

    def created_at_str
      created_at.to_s
    end

    def created_at_utc
      created_at.getutc.iso8601
    end
  end
end
