class NullUser
  def admins?(messageboard)
    false
  end

  def can_read_messageboard?(messageboard)
    messageboard.public?
  end

  def id
    0
  end

  def member_of?(messageboard)
    false
  end

  def name
    'Anonymous User'
  end

  def superadmin?
    false
  end

  def valid?
    false
  end
end
