# frozen_string_literal: true
RSpec.configure do |c|
  # always reset notifiers -- it's easier this way
  c.around(:example) do |example|
    example.run
    notifiers = Thredded.class_variable_get(:@@notifiers)
    if notifiers
      if Thredded::PerNotifierPref.class_variable_defined?(:@@notifier_keys)
        notifier_keys = Thredded::PerNotifierPref.class_variable_get(:@@notifier_keys) || []
        notifier_keys.each do |key|
          Thredded::PerNotifierPref.send(:remove_method, key)
          Thredded::PerNotifierPref.send(:remove_method, "#{key}=")
        end
        Thredded::PerNotifierPref.class_variable_set(:@@notifier_keys, nil)
      end
    end
    Thredded.class_variable_set(:@@notifiers, nil)
  end

  c.around(:example, :thredded_reset) do |example|
    # if you specify some variables in thredded_reset we'll reset them after running, except notifiers which get
    # reset always
    thredded_reset = (example.metadata[:thredded_reset] || []).reject { |v| v.to_s == '@@notifiers' }.map do |variable|
      [variable, Thredded.class_variable_get(variable)]
    end
    example.run
    thredded_reset.each do |variable, value|
      Thredded.class_variable_set(variable, value)
    end
  end
end
