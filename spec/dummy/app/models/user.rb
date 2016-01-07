class User < ActiveRecord::Base
  def to_s
    name
  end

  def to_param
    name.parameterize
  end

  def email
    super || "#{name}@gmail.com"
  end
end
