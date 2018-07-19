# frozen_string_literal: true

require_dependency 'themes'

class SettingsController < ApplicationController
  def update_locale
    locale = params[:locale].to_s
    if I18n.available_locales.map(&:to_s).include?(locale)
      cookies.permanent['locale'] = locale
      set_locale
      redirect_to redirect_url, status: 303
    else
      head :bad_request
    end
  end

  def update_theme
    theme = params[:theme].to_s
    if Themes::VALID_THEMES.include?(theme)
      cookies.permanent['app-theme'] = theme
      redirect_to redirect_url, status: 303
    else
      head :bad_request
    end
  end

  private

  def redirect_url
    url = request.headers['Referer']
    url = thredded.root_path if url.nil? || url == request.url
    uri = URI(url)
    uri.host = request.host
    uri.port = request.port
    uri.scheme = request.scheme
    uri.to_s
  end
end
