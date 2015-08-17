Thredded.user_class = 'User'
Thredded.user_name_column = :name
Thredded.user_path = ->(user) { main_app.user_path(user.to_param) }
Thredded.email_incoming_host = 'incoming.example.com'
Thredded.email_from = 'no-reply@example.com'
Thredded.email_outgoing_prefix = '[Thredded] '
