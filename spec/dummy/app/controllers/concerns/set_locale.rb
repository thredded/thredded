# frozen_string_literal: true

module SetLocale
  extend ActiveSupport::Concern

  included do
    # Avoid around_action here because it pollutes the stack trace.
    before_action :set_locale
    after_action :restore_locale
  end

  private

  def set_locale
    locale = if cookies['locale'] && I18n.available_locales.map(&:to_s).include?(cookies['locale'])
               cookies['locale']
             else
               http_accept_language.language_region_compatible_from(I18n.available_locales)
             end || I18n.default_locale
    @i18n_locale_was = I18n.locale
    I18n.locale = locale
  end

  def restore_locale
    I18n.locale = @i18n_locale_was
  end
end
