module ApplicationHelper
  VALID_THEMES = %w(default dark)

  def themes
    VALID_THEMES
  end

  def current_theme
    cookie_theme = cookies['thredded-theme']
    VALID_THEMES.include?(cookie_theme) ? cookie_theme : VALID_THEMES[0]
  end
end
