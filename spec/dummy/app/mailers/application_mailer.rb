# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  layout 'email'
end
