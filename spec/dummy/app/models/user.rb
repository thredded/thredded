# frozen_string_literal: true

class User < ActiveRecord::Base
  validates :name, presence: true

  # Finds the post by its ID, or raises {Errors::UserNotFound}.
  # @param id [String, Number]
  # @return [User]
  # @raise [Errors::UserNotFound] if the user with the given ID does not exist.
  def self.find!(id)
    find_by(id: id) || fail(Errors::UserNotFound)
  end

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
