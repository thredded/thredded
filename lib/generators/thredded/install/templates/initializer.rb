# Thredded configuration

# ==> User Configuration
# The name of the class your app uses for your users.
# By default the engine will use 'User' but if you have another name
# for your user class - change it here.
Thredded.user_class = 'User'

# User name column, used in @mention syntax and should be unique.
# This is the column used to search for users' names if/when someone is @ mentioned.
Thredded.user_name_column = :name

# The path (or URL) you will use to link to your users' profiles.
# When linking to a user, Thredded will use this lambda to spit out
# the path or url to your user. This lambda is evaluated in the view context.
Thredded.user_path = lambda do |user|
  user_path = :"#{Thredded.user_class.name.underscore}_path"
  main_app.respond_to?(user_path) ? main_app.send(user_path, user) : "/users/#{user.to_param}"
end

# User avatar URL. rb-gravatar gem is used by default:
Thredded.avatar_url = ->(user) { Gravatar.src(user.email, 128, 'mm') }

# ==> Permissions Configuration
# By default, thredded uses a simple permission model, where all the users can post to all message boards,
# and admins and moderators are determined by a flag on the users table.

# The name of the moderator flag column on the users table.
Thredded.moderator_column = :admin
# The name of the admin flag column on the users table.
Thredded.admin_column = :admin

# This model can be customized further by overriding a handful of methods on the User model.
# For more information, see app/models/thredded/user_extender.rb.

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
# Set the layout for rendering the thredded views.
Thredded.layout = 'thredded/application'

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
