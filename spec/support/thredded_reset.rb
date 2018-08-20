# frozen_string_literal: true

RSpec.configure do |c|
  # always reset notifiers -- it's easier this way
  c.around do |example|
    example.run
    Thredded.instance_variable_set(:@notifiers, nil)
  end

  c.around(:example, :thredded_reset) do |example|
    # if you specify some variables in thredded_reset we'll reset them after running, except notifiers which get
    # reset always
    thredded_reset = ((example.metadata[:thredded_reset] || []) - %i[@notifiers]).map do |variable|
      [variable, Thredded.instance_variable_get(variable)]
    end
    example.run
    thredded_reset.each do |variable, value|
      Thredded.instance_variable_set(variable, value)
    end
  end
end
