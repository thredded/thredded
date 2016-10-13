# v0.7.0

This release contains new functionality and backwards-incompatible changes.

**NB:** If updating to this version from 0.6.x, you will need to copy and run [this migration](https://github.com/thredded/thredded/blob/1aba2433d7df1bd00478dd156d8f2526d36aad55/db/upgrade_migrations/20160723012349_upgrade_v0_6_to_v0_7.rb) after upgrading the gem.

## Added

* Messageboard ordering is now configurable. Three options are provided:
  * `position`: (default) set the position manually via the `position` column which defaults to the creation order,
     newly created messageboards got to the bottom.
  * `last_post_at_desc`: messageboards with most recent posts first.
  * `topics_count_desc`: messageboards with most topics first (previous default).
  Messageboard groups are now ordered by the new `position` column which also defaults to the creation order.
  [#404](https://github.com/thredded/thredded/pull/404)
* The users that follow a topic can now be displayed on the topic page. This is controlled by a configuration option
  and is off by default. [#392](https://github.com/thredded/thredded/pull/392)

## Changed

* Messageboard group name uniqueness is now enforced. If you had non-unique names before, the upgrade migration will
  deduplicate them. If you need to maintain previous behaviour, you can use
  [this workaround](https://github.com/thredded/thredded/issues/318#issuecomment-242944339).
  [#318](https://github.com/thredded/thredded/issues/318)
* Messageboards ordering now defaults to the order they were created in (previously: topics count).
  [#404](https://github.com/thredded/thredded/pull/404)
* The read topics in the topics list are now also distinguished from the unread ones by their font weight.
  [#394](https://github.com/thredded/thredded/pull/394)
* Following / not following indicators are now displayed on the topics list. The "following" icon ![Follow icon](https://raw.githubusercontent.com/wiki/thredded/thredded/img/follow.png) is displayed on
  the topic page if the topic is being followed by the user.
  [#394](https://github.com/thredded/thredded/pull/394)

## Fixed

* Last topic tracking in messageboards now correctly reflects the topic when one is deleted.
  [#403](https://github.com/thredded/thredded/pull/403)
* Last post tracking in topics now always correctly reflects the last post and its timestamp. New `last_post_at` columns
  have been added to `topics` and `private_topics` to enable this.
  [#405](https://github.com/thredded/thredded/issues/405)
* Thredded now uses the new `User#thredded_display_name` method for displaying the user's name in links.
  Previously, Thredded used `User#to_s`. This new method uses `Thredded.user_name_column` by default,
  simplifying the setup. [#398](https://github.com/thredded/thredded/issues/398)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.6.3...v0.7.0.

# v0.6.3

This release contains minor bugfixes and adds a Mark All as Read feature to the private messages.

## Added

* A way to mark all unread private messages as read. [#260](https://github.com/thredded/thredded/pull/260)

## Fixed

* Last topic post and last messageboard topic is kept in sync correctly with regards to moderation state changes.
[#384](https://github.com/thredded/thredded/issues/384) [#387](https://github.com/thredded/thredded/issues/387)
* Posts and private posts are now ordered by created at and not by ID, to avoid ordering issues in cases such as
imported content. [#360](https://github.com/thredded/thredded/issues/360)
* The global preferences URL now works when the Thredde URL helpers are included into another engine.
[#355](https://github.com/thredded/thredded/pull/355)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.6.2...v0.6.3.

# v0.6.2

This is a minor bugfix release.

## Fixed

* Moderating posts, topics, and users no longer changes their `updated_at` attribute.
* Posts and topics that are not yet visible to all users no longer appear as last posts / topics in the respective
  topic / messageboard.
* Cleaned up dependencies.

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.6.1...v0.6.2.

# v0.6.1

This is a minor bugfix release.

## Added

* Adds an Activity tab to moderation, with a list of all the forum topics and posts, most recent first.

## Fixed

* Moderation history rendering of deleted content.
* Various bugs in @-mentions and highlighting.

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.6.0...v0.6.1.

# 0.6.0 - 2016-06-12

**NB:** If updating to this version from 0.5.x, you will need to copy and run [this migration](https://github.com/thredded/thredded/blob/66f64068b9501ff4e8686c95894b6795aae6082f/db/upgrade_migrations/20160611094616_upgrade_v0_5_to_v0_6.rb).

## Added

* Adds a Users tab to moderation, where individual users can be moderated.
* Improves the display of posts in the moderation, showing the topic and
  whether the post started the topic.
* Thredded now provides a way to render a user's recent posts in the main_app.

## Changed

* Moderators are now shown all content, including blocked content. A notice is shown on blocked content.

## Fixed

* Fixed a bug that prevented user deletion in main_app if they had posted on the forums.

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.5.1...v0.6.0.

# 0.5.1

This is a minor bugfix release.

## Fixed

* Security: only allow http, https, and relative iframe src protocols.
* Security: sanitization filter is applied last (no actual issues were discovered, but this is how it should be).
* Fixes multiple issues with @-mentions parsing and highlighting. [e6357ff](https://github.com/thredded/thredded/commit/e6357ffb45bf9118a9f5c7df0d436bdffe0a84c6)
* Minor CSS fixes.
* Messageboards index page title is now i18n'd.
* The "Delete Topic" now shows a confirmation dialog.
* Editing posts by deleted users no longer throws an exception.

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.5.0...v0.5.1.

# 0.5.0

**NB:** If updating to this version from 0.4.x, you will need to copy and run [this migration](https://github.com/thredded/thredded/blob/5e203c8eec05919d97f4d26fa2a1fc3081e992a7/db/upgrade_migrations/20160501151908_upgrade_v0_4_to_v0_5.rb).

## Added

This release includes two major features:

* Topic subscriptions and an improved notifications system. [#310](https://github.com/thredded/thredded/pull/310)
* A basic [moderation system](https://github.com/thredded/thredded#moderation). [#45](https://github.com/thredded/thredded/issues/45)

Additionally, content formatting is now easier to configure. [#321](https://github.com/thredded/thredded/pull/321)

## Changed

* `<figure>` and `<figcaption>` are now allowed in formatted post content.

## Fixed

* YouTube embeds. [#314](https://github.com/thredded/thredded/issues/314)
* Creating a topic now marks it as read. [#322](https://github.com/thredded/thredded/issues/322)
* Dates older than a year now display the year. [#309](https://github.com/thredded/thredded/issues/309)
* `<a>` tags without `href` in posts no longer cause an exception. [#313](https://github.com/thredded/thredded/issues/313)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.4.0...v0.5.0.

# 0.4.0 - 2016-05-21

**NB:** If updating to this version from 0.3.x, you will need to copy and run [this migration](https://github.com/thredded/thredded/blob/559fc205b9ee405abfe3968b981254f01f928027/db/upgrade_migrations/20160429222452_upgrade_v0_3_to_v0_4.rb).

## Fixed

* Results from messageboards that cannot be read by the user no longer appear in the search results. [77293c](https://github.com/thredded/thredded/commit/77293c88980ec97f178d9a47405fdf915cd36ccc)
* Word-wrap is no longer a hard one (wraps in the middle of a word), and now wraps in a more
  acceptable spot - after words, at hyphens, etc.
* Mailers now use permalinks to posts that always redirect to the correct page number. [#301](https://github.com/thredded/thredded/pull/301)

## Added

* Messageboard groups ([#261](https://github.com/thredded/thredded/issues/261)) and editing ([#303](https://github.com/thredded/thredded/pull/303)).
* Spoiler(s) tag for post contents [5c8102a](https://github.com/thredded/thredded/commit/5c8102) `[spoiler]vader is luke's father[spoiler]`
* Styled blockquote tags.
* Empty partials before and after post textareas (for customization and extensibility) [#293](https://github.com/thredded/thredded/pull/293)
* New topic form page now allows pre-filling the fields from URL parameters. [#297](https://github.com/thredded/thredded/issues/297)
* Date format fix for dates older than 1 week. [9d71ba](https://github.com/thredded/thredded/commit/9d71ba2f1ddeac761e084e872a4b0a84ab62e35c)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.3.2...v0.4.0.

# 0.3.2 - 2016-05-04

* Main app routes are delegated correctly when using the standalone layout. [8a2ff56](https://github.com/thredded/thredded/commit/8a2ff56f73afe0d6e8e8ecede9666b8d65817fa3)
* Posts now have `word-break: break-all` applied to prevent overly long string form breaking the layout. [#267](https://github.com/thredded/thredded/issues/267)
* I18n for [rails-timeago](https://github.com/jgraichen/rails-timeago). [#270](https://github.com/thredded/thredded/issues/270)

# 0.3.1 - 2016-05-01

## Fixed

* Mobile Safari navigation UI bug. [#265](https://github.com/thredded/thredded/issues/265)
* iframe security vulnerability. [04fa108a7](https://github.com/thredded/thredded/commit/04fa108a7da177ee25c7d215f4c43dab2875a0c1)
* Markdown blockquotes. [#259](https://github.com/thredded/thredded/pull/259)
* Read state tracking timestamp issue. [2c85076ba](https://github.com/thredded/thredded/commit/2c85076ba1034a3664abc887f89b22e67405564d)
* Search input styles in various OS/Browser combinations.
* (Private)Topic read permission denied error. [#269](https://github.com/thredded/thredded/issues/269)

## Added

* Brazilian Portuguese translation. [#264](https://github.com/thredded/thredded/pull/264).

# 0.3.0 - 2016-04-22

Thredded now supports Rails 4.2+ only.

Thredded now also fully supports the latest Rails 5 beta, but currently this requires using master versions of certain
gems. See [rails_5_0.gemfile](https://github.com/thredded/thredded/blob/master/spec/gemfiles/rails_5_0.gemfile)
for more information.

## Fixed

* (Private)Topic slugs re-generate at appropriate time
  [28c09f4](https://github.com/thredded/thredded/commit/28c09f40804d3a71bbc12c56819a8acab3c94f2d)
* Editing topics and private message subjects. [#235](https://github.com/thredded/thredded/pull/235)
* Require login for `PrivateTopicsController`.
  [5739f5](https://github.com/thredded/thredded/commit/5739f50a513377392205a41958b5a2d3ca25dc10)
* Current user method now configurable via initializer.
  [#234](https://github.com/thredded/thredded/pull/234)
* Pagination and possible route conflicts throughout. [#202](https://github.com/thredded/thredded/pull/202)
* Redirects to the correct page after posting a reply. [#205](https://github.com/thredded/thredded/pull/205)
* Search with special `by:user` and `in:category` qualifiers. [#206](https://github.com/thredded/thredded/pull/206)
* Private topics now validate presence of at least one user other than the creator. [#207](https://github.com/thredded/thredded/pull/207)
* "Not found" and "Permission denied" errors now render with the correct response codes. [#208](https://github.com/thredded/thredded/pull/208)
* Thredded user associations are now correctly nullified / destroyed when a user is destroyed in the parent app.

## Added

* Dummy App renamed to "Thredded Demo" and demo deployed to Heroku
* Added vimeo and youtube auto-embed support. [#216](https://github.com/thredded/thredded/pull/216)
* Ability to delete posts. [#214](https://github.com/thredded/thredded/pull/214)
* Global search across all messageboards. [#215](https://github.com/thredded/thredded/pull/215)
* Global notification settings, message notification settings. [#210](https://github.com/thredded/thredded/pull/210)
* Private topic user select now looks prettier and loads the user via AJAX, instead of generating a huge select with all
  the users. [#199](https://github.com/thredded/thredded/pull/199).
* The theme is now more customizable thanks to a number of fixes and new variables. [#197](https://github.com/thredded/thredded/pull/197)
* The topic read state is now visually updated on click. [#198](https://github.com/thredded/thredded/pull/198)
* Email preview classes are now provided. [#196](https://github.com/thredded/thredded/pull/196).
* I18n'd a *bunch* of static copy. (Thanks @glebm!)

## Changed

* Navigation layout/design updated [ec699fd](https://github.com/thredded/thredded/commit/ec699fd)
* Changed from using Bbcode OR Markdown to *both*, simultaneously.
  [#221](https://github.com/thredded/thredded/pull/221)
* Removed Timecop in favor of built-in rails `travel_to` helper.
  [#226](https://github.com/thredded/thredded/pull/226)
* Moved from CanCanCan to Pundit. [#228](https://github.com/thredded/thredded/pull/228)
* Renamed "Private Topics" to "Private Messages"
* Renamed `$thredded-base-font-color` to `$thredded-text-color`.
* Renamed `$thredded-base-background-color` to `$thredded-background-color`.

# 0.2.2 - 2016-04-04

## Fixed

* Gemspec had been missing the file-listing for a while therefore previous gem versions would have
  had installation issues. To use previous, broken, versions refer to the changelog notes for each
  below.
* Images are now no larger than the post container div. CSS now makes sure the images are
  appropriately sized.
* Fix an incorrectly closed div in `thredded/topics#show`
* Small fix for topics count circle - making sure 3 digit numbers fit in container circle.

## Added

* Rake task added to copy emojis to correct location in parent application.
* Properly styled categories in `thredded/topics#index`


# 0.2.1 - 2016-04-03

To install, in your Gemfile:

```
gem 'thredded', git: 'https://github.com/thredded/thredded.git', tag: 'v0.2.1'
```

## Changed

* All migrations have been squashed into one single db-agnostic migration.
* README has been updated with better instructions/support

# 0.2.0 - 2016-04-03

To install, in your Gemfile:

```
gem 'thredded', git: 'https://github.com/thredded/thredded.git', tag: 'v0.2.0'
```

## TLDR

A lot was updated. Apologies for not keeping this updated since `0.1.0`!

## Added

* Entirely new default theme. Courtesy @kylefiedler
* Full-text search abstracted out to gem (db_text_search) thanks to @glebm
* Rack-mini-profiler added to dummy app

## Changed

* Rails depedency bumped up to raisl 4.1+
* User permissions have been simplified considerably. (@glebm)
* Changed from using Q gem to ActiveJob
* Move SeedDatabase class out of an autoloaded path since it's for dev only (@cgunther)


## Fixed

* User path corrected (@saturnflyer)
* Move requiring turbolinks from thredded to dummy app (@cgunther)
* Fix location of layout in install generator (@mlaco)

##

# 0.1.0 - 2015-06-29

## Added

* Rake task to spin up a web server using the dummy application
* Rake task to assign user to a superadmin role
* A relatively large effort was put in effect for 0.1.0 to provide more thorough support for themes, new css and design, a small bit of javascript.
* Views have had a nice overhaul.
* Provide a generator that installs the default theme and integrates the associated css framework (if necessary). In the first theme we're using bourbon and neat. In the future - probably including foundation and bootstrap.
* Add a Dockerfile and docker-compose.yml to aid in getting a fully working instance of the thredded dummy app up and running.
* Instead of having a messageboard "setup" controller that is only available on the first run of the gem, move it over to `messageboards#new`.

## Changed

* Instead of creating a messageboard only once, allow superadmins to create new messageboards whenever through the messageboards resource.
* Use Puma instead of Webrick for the dev server
* Oft-used form elements (topics, posts) use the required html attribute.

## Fixed

* Remove Gemfile.lock from the repo
* Active users now shows the current user in addition to everyone else on the first (without having to refresh).


# 0.0.14

## Changed

* Until this release PrivateTopic inherited from Topic and used STI to reuse that table. Over time this led to some intermingling of concerns and more than the occasional shotgun surgery. As of now the Topic class has been split into Topic AND PrivateTopic, each with their own table.
* Provide means to display, or inspect, the unread private topics count. This now allows us to see if there are any private topics that one has not read.
* Add queue support for multiple background job libraries using the Q gem. Previous to now the only instances where we really cared about shoving something in the background was when we sent out mail - this is a bit myopic. There are several cases where some processes could/should be put into the background - hence needing a queue. The explicit requirement of a specific queue library is something we should avoid so the Q gem was pulled in to provide the abstraction layer that allows one of several libraries to be used - resque, sidekiq, delayed_job, or, the default, an in-memory threaded queue.
* Update rails dependency from `'~> 4.0.0'` to `'>= 4.0.0'`
* Replace nested forms with form objects
* Remove unused columns in tables - `state` from `thredded_topics`.
* Link to user from post on topic page (thanks @taylorkearns!)

## Fixed

* Fix issue where post did not inherit the test filter set per messagebard
* Building a new post for reply form must use the parent messageboard filter

# 0.0.13

## Fixed

* Users' messageboard preferences are created if one does not exist for a given messageboard. This had caused people who had not updated their own preferences to NOT receive @ notifications by default. As of this release they will, by default, receive @'s and private thread notifications until they change their preferences.

## Changed

* A topic's categories can now be rendered in the view. `categories/category` partial addded.
* Adding attachments to a post has been removed. (Attachment model and association will be removed in 0.0.15)

# 0.0.12

## Fixed

* Requiring the sql search builder explicitly fixes the issue where anonymous visitors would not be able to search
* Users, when they edit a topic they started, should not be able to pin/lock it. This has been changed to only allow admins to do so.
* bbcode now renders line-breaks
* html is now better sanitized

## Changed

* Replace the previously used inheritance-based filter chain with
[html-pipeline](https://github.com/jch/html-pipeline). Much better.
* Replace bb-ruby with bbcoder gem.
* Replace `redcarpet` with `github-markdown`
* Provide a more explicit contract between the gem and the parent application with regards to the layout the thredded views will render within
* `:thredded_page_title` and `:thredded_page_id` provided as content blocks that may be yielded to the layout
* Allow gravatar image to be overridden in the config
* Thredded::PostDecorator#user_link now available for use in post-related views

# 0.0.11

## Feature / Bug Fix

* Up until now the manner by which file uploads (via Carrierwave) had its storage
location determined was in the uploaded classes themselves. This commit allows the
location to be set from the Thredded module itself - `Thredded.file_storage` - to
either :file or :fog.

# 0.0.10

## Fixed

* Fixed: private topics not being created correctly
* Test coverage for above

# 0.0.8

## Fixed

* Make sure messageboard slug is populated upon creation

## Changed

* Refactor controllers for a little more cleanliness
* Exceptions raised and caught instead of asking for existence of objects
* Update pagination path format

# 0.0.7

## Fixed

* Get search back to working

# 0.0.6

## Changed

* Update rails dependency in gemspec to use a `~>` instead of `>=`

## Fixed

* Fix `convert_textile_to_markdown` migration to use proper sql syntax

# 0.0.5

## New Features

* A CHANGELOG!

## Fixed

* Fix `PostsController#topic` to ensure the `user_topic_reads` association is eager loaded
* Make that `topic` method pass along to an obviously named and intention revealing method
* Delete the filter select from `posts/_form` partial
* require `thredded/at_notifier` in `thredded.rb` (thanks @srussking)

## Changed

* Introduce a more robust `MessageboardDecorator`
* Allow `messagebord` obj or collection to be decorated with `#decorate` method
* Introduce `NullTopic` to stand in for instances where a topic is not found
* remove `rspec/autorun` from `spec_helper`
