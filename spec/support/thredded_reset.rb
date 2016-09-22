# frozen_string_literal: true
RSpec.configure do |c|
  c.around(:example, :thredded_reset) do |example|
    # if you specify some variables in thredded_reset we'll reset them after running
    thredded_reset = (example.metadata[:thredded_reset] || []).map do |variable|
      [variable, Thredded.class_variable_get(variable)]
    end
    example.run
    thredded_reset.each { |variable, value| Thredded.class_variable_set(variable, value) }
  end
end
