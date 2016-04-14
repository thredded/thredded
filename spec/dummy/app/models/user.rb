# frozen_string_literal: true
class User < ActiveRecord::Base
  validates :name, presence: true

  def to_s
    name
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
