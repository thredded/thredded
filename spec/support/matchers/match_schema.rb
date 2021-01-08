# spec/support/matchers/match_schema.rb
RSpec::Matchers.define :match_schema do |schema|
  match do |response|
    @result = schema.call(JSON.parse(response.body))
    @result.success?
  end

  def failure_message
    @result.errors.to_h
  end
end
