# frozen_string_literal: true

require_dependency 'themes'

module ApplicationHelper
  include Rails.application.routes.url_helpers

  def themes
    Themes::VALID_THEMES
  end

  def current_theme
    cookie_theme = cookies['app-theme']
    themes.include?(cookie_theme) ? cookie_theme : themes[0]
  end
end
