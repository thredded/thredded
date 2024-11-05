# frozen_string_literal: true
SimpleCov.start do
  add_filter '/spec/'
  add_group 'Commands', 'app/commands'
  add_group 'Controllers', 'app/controllers'
  add_group 'Forms', 'app/forms'
  add_group 'Helpers', 'app/helpers'
  add_group 'Jobs', 'app/jobs'
  add_group 'Mailers', %w(app/mailers app/mailer_previews)
  add_group 'Models', 'app/models'
  add_group 'Policies', 'app/policies'
  add_group 'View models', 'app/view_models'
  add_group 'Lib', 'lib/'
  formatter SimpleCov::Formatter::HTMLFormatter unless ENV['CI']
end
