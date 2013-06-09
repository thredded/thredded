module Thredded
  module ApplicationHelper
    def method_missing(method, *args, &block)
      main_app.send(method, *args, &block)
    rescue NoMethodError
      super
    end
  end
end
