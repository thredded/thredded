# frozen_string_literal: true
module Thredded
  class BaseTopicDecorator < SimpleDelegator
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def original
      __getobj__
    end
  end
end
