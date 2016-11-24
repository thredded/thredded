# frozen_string_literal: true
# Thredded configuration

# ==> User Configuration
# The name of the class your app uses for your users.
# By default the engine will use 'User' but if you have another name
# for your user class - change it here.
Thredded.user_class = 'User'

# User name column, used in @mention syntax and should be unique.
# This is the column used to search for users' names if/when someone is @ mentioned.
Thredded.user_name_column = :name

# User display name method, by default thredded uses the user_name_column defined above
# You may want to use :to_s or some more elaborate method
# Thredded.user_display_name_method = :to_s

# The path (or URL) you will use to link to your users' profiles.
# When linking to a user, Thredded will use this lambda to spit out
# the path or url to your user. This lambda is evaluated in the view context.
Thredded.user_path = lambda do |user|
  user_path = :"#{Thredded.user_class.name.underscore}_path"
  main_app.respond_to?(user_path) ? main_app.send(user_path, user) : "/users/#{user.to_param}"
end

# This method is used by Thredded controllers and views to fetch the currently signed-in user
Thredded.current_user_method = :"current_#{Thredded.user_class.name.underscore}"

# User avatar URL. rb-gravatar gem is used by default:
Thredded.avatar_url = ->(user) { Gravatar.src(user.email, 128, 'mm') }

# ==> Permissions Configuration
# By default, thredded uses a simple permission model, where all the users can post to all message boards,
# and admins and moderators are determined by a flag on the users table.

# The name of the moderator flag column on the users table.
Thredded.moderator_column = :admin
# The name of the admin flag column on the users table.
Thredded.admin_column = :admin

# Whether posts and topics pending moderation are visible to regular users.
Thredded.content_visible_while_pending_moderation = true

# Whether users that are following a topic are listed on topic page.
Thredded.show_topic_followers = false

# This model can be customized further by overriding a handful of methods on the User model.
# For more information, see app/models/thredded/user_extender.rb.

# ==> Ordering configuration

# How to calculate the position of messageboards in a list:
# :position            (default) set the position manually (new messageboards go to the bottom, by creation timestamp)
# :last_post_at_desc   most recent post first
# :topics_count_desc   most topics first
Thredded.messageboards_order = :position

# ==> Email Configuration
# Email "From:" field will use the following
# Thredded.email_from = 'no-reply@example.com'

# Emails going out will prefix the "Subject:" with the following string
# Thredded.email_outgoing_prefix = '[My Forum] '

# ==> View Configuration
# Set the layout for rendering the thredded views.
Thredded.layout = 'thredded/application'

# ==> Post Content Formatting
# Customize the way Thredded handles post formatting.

# Change the default html-pipeline filters used by thredded.
# E.g. to replace default emoji filter with your own:
# Thredded::ContentFormatter.after_markup_filters[
#   Thredded::ContentFormatter.after_markup_filters.index(HTML::Pipeline::EmojiFilter)] = MyEmojiFilter

# Change the HTML sanitization settings used by Thredded.
# See the Sanitize docs for more information on the underlying library: https://github.com/rgrove/sanitize/#readme
# E.g. to allow a custom element <custom-element>:
# Thredded::ContentFormatter.whitelist[:elements] += %w(custom-element)

# ==> User autocompletion (Private messages and @-mentions)
# Thredded.autocomplete_min_length = 2 lower to 1 if have 1-letter names -- increase if you want

# ==> Error Handling
# By default Thredded just renders a flash alert on errors such as Topic not found, or Login required.
# Below is an example of overriding the default behavior on LoginRequired:
#
# Rails.application.config.to_prepare do
#   Thredded::ApplicationController.module_eval do
#     rescue_from Thredded::Errors::LoginRequired do |exception|
#       @message = exception.message
#       render template: 'sessions/new', status: :forbidden
#     end
#   end
# end

# ==> View hooks
#
# Customize the UI before/after/replacing individual components.
# See the full list of view hooks and their arguments by running:
#
#     $ grep view_hooks -R --include '*.html.erb' "$(bundle show thredded)"
#
# Rails.application.config.to_prepare do
#   Thredded.view_hooks.post_form.content_text_area.config.before do |form:, **args|
#     # This is called in the Thredded view context, so all Thredded helpers and URLs are accessible here directly.
#     'hi'
#   end
# end

# ==> Topic following
#
# By default, a user will be subscribed to a topic they've created. Uncomment this to not subscribe them:
#
# Thredded.auto_follow_when_creating_topic = false
#
# By default, a user will be subscribed to (follow) a topic they post in. Uncomment this to not subscribe them:
#
# Thredded.auto_follow_when_posting_in_topic = false
#
# By default, a user will be subscribed to the topic they get @-mentioned in.
# Individual users can disable this in the Notification Settings.
# To change the default for all users, simply change the default value of the `follow_topics_on_mention` column
# of the `thredded_user_preferences` and `thredded_user_messageboard_preferences` tables.

# ==> Notifiers
#
# Change how users can choose to be notified, by adding notifiers here, or removing the initializer altogether
#
# default:
# Thredded.notifiers = [Thredded::EmailNotifier.new]
#
# none:
# Thredded.notifiers = []
#
# add in (must install separate gem (under development) as well):
# Thredded.notifiers = [Thredded::EmailNotifier.new, Thredded::PushoverNotifier.new(ENV['PUSHOVER_APP_ID'])]
