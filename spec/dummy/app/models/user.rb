class User < ActiveRecord::Base
  attr_accessible :name, :email

  def to_s
    name
  end
end
