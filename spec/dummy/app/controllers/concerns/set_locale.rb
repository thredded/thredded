# frozen_string_literal: true
module SetLocale
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  private

  def set_locale
    locale = if cookies['locale'] && I18n.available_locales.map(&:to_s).include?(cookies['locale'])
               cookies['locale']
             else
               http_accept_language.language_region_compatible_from(I18n.available_locales)
             end || I18n.default_locale
    I18n.with_locale(locale) { yield }
  end
end
