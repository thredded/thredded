# Thredded configuration

# ==> User Configuration
# The name of the class your app uses for your users.
# By default the engine will use 'User' but if you have another name
# for your user class - change it here.
Thredded.user_class = 'User'

# User name column, used in @mention syntax and should be unique.
Thredded.user_name_column = :name

# The path (or URL) you will use to link to your users' profiles.
# When linking to a user, Thredded will use this lambda to spit out
# the path or url to your user.
Thredded.user_path = ->(user) { "/users/#{user}" }

# User avatar URL. Thredded uses Gravatar via the gravtastic gem by default.
# Visit the gravtastic project - https://github.com/chrislloyd/gravtastic#usage
# for further instructions on how to customize.
Thredded.avatar_url = ->(_user, post) { post.gravatar_url(default: 'mm') }

# ==> Email Configuration
# Email "From:" field will use the following
# Thredded.email_from = 'no-reply@example.com'

# Incoming email will be directed to this host
# Thredded.email_incoming_host = 'example.com'

# Emails going out will prefix the "Subject:" with the following string
# Thredded.email_outgoing_prefix = '[My Forum] '

# Reply to field for email notifications
# Thredded.email_reply_to = -> postable { "#{postable.hash_id}@#{Thredded.email_incoming_host}" }

# ==> Background Job/Queue Configuration
# Thredded uses the 'Q' gem, which provides a common interface for several
# different background job / queueing libraries. The supported queue
# backends are:
#
#   :threaded_in_memory_queue
#   :sidekiq
#   :resque
#   :delayed_job
#
# By default, the in-memory queue is turned on, but we recommend sidekiq.
Thredded.queue_backend = :threaded_in_memory_queue

# Whether or not to inline the jobs being processed. Typically you would only
# want to turn this on for when the test suite is being run.
Thredded.queue_inline = Rails.env.test?

# If using the threaded in-memory queue it will default its log level to
# `Logger::WARN` but if you would like more information, change it to
# `Logger::INFO` or `Logger::DEBUG`.
# Thredded.queue_memory_log_level = Logger::WARN

# ==> View Configuration
# When rendering the thredded views you can specify which layout you would
# like them to use. It defaults to 'thredded' and will look for it in
# `app/views/layouts/thredded.html.erb`.
Thredded.layout = 'thredded'

# ==> Asset / File Storage Configuration
# Root location where you have placed emojis (used when rendering posts).
# If you're hosting on a platform that allows you to keep your files local
# to your app - this might not be necessary. If you're hosting somewhere
# with an ephemeral filesystem, like heroku, you'll need to point this to
# wherever you store files on the cloud.
#
# Thredded.asset_root = ''
# Thredded.asset_root = 'https://my-app-bucket.s3.amazonaws.com/assets'
#
# Where carrierwave will be storing its files - on the cloud, or filesystem.
# Configure :fog with your own carrierwave initializer.
Thredded.file_storage = Rails.env.production? ? :fog : :file
