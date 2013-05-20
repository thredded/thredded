RSpec.configure do |config|
  config.before do
    ActiveRecord::Base.observers.disable :all

    observers = example.metadata[:observer] || example.metadata[:observers]

    if observers
      ActiveRecord::Base.observers.enable *observers
    end
  end
end
