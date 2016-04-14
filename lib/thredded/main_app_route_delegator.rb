# frozen_string_literal: true
module Thredded
  # If thredded is rendered within an application layout, this module allows
  # referring to the routes in the layout directly, without having to use `main_app.`.
  module MainAppRouteDelegator
    # delegate url helpers to main_app
    def method_missing(method, *args, &block)
      if main_app_route_method?(method)
        main_app.send(method, *args)
      else
        super
      end
    end

    def respond_to?(method, *args)
      super || main_app_route_method?(method)
    end

    private

    def main_app_route_method?(method)
      method.to_s =~ /_(?:path|url)$/ && main_app.respond_to?(method)
    end
  end
end
