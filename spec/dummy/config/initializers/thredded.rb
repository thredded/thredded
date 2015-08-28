Thredded.user_class = 'User'
Thredded.user_name_column = :name
Thredded.user_path = ->(user) { main_app.user_path(user.to_param) }
Thredded.email_incoming_host = 'incoming.example.com'
Thredded.email_from = 'no-reply@example.com'
Thredded.email_outgoing_prefix = '[Thredded] '
Thredded.layout = 'application' unless ENV['THREDDED_DUMMY_LAYOUT_STANDALONE']
Thredded.avatar_url = ->(_user, post) { post.gravatar_url(default: 'retro') }
