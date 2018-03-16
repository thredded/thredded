# frozen_string_literal: true

class User < ActiveRecord::Base
  validates :name, presence: { message: I18n.t('presence_validation_message', locale: :en) }

  def to_s
    fail 'Deliberately failing so we can test'
  end

  def to_param
    name.parameterize
  end

  def name=(value)
    super(value.to_s.strip)
  end

  def email
    super || "#{name}@gmail.com"
  end

  def admin=(value)
    super(value || false)
  end
end
