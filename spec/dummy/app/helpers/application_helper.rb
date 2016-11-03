# frozen_string_literal: true
module ApplicationHelper
  VALID_THEMES = %w(day night).freeze

  def themes
    VALID_THEMES
  end

  def current_theme
    cookie_theme = cookies['thredded-theme']
    VALID_THEMES.include?(cookie_theme) ? cookie_theme : VALID_THEMES[0]
  end
end
