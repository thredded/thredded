::Griddler.configure do |config|
  config.processor_class = Thredded::EmailProcessor
  config.to = :token
end
