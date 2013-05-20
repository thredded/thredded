class EagerLoad
  def initialize(association)
    @association = association
  end

  def matches?(target)
    @target = target
    @target.default_scopes.find_all { |scope|
      scope[:include] == @association
    }.present?
  end

  def failure_message_for_should
    "expected #{@target.class.name} to eager load #{@association}"
  end

  def failure_message_for_should_not
    "expected #{@target.class.name} to not eager load #{@association}"
  end
end

def eager_load(expected)
  EagerLoad.new(expected)
end
