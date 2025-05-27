# Thredded
[![Code Climate](https://codeclimate.com/github/thredded/thredded/badges/gpa.svg)](https://codeclimate.com/github/thredded/thredded)  [![Test Coverage](https://codeclimate.com/github/thredded/thredded/badges/coverage.svg)](https://codeclimate.com/github/thredded/thredded/coverage) [![Inline docs](http://inch-ci.org/github/thredded/thredded.svg?branch=main)](http://inch-ci.org/github/thredded/thredded) [![Gitter](https://badges.gitter.im/thredded/thredded.svg)](https://gitter.im/thredded/thredded?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![CI](https://github.com/thredded/thredded/actions/workflows/build.yml/badge.svg)](https://github.com/thredded/thredded/actions/workflows/build.yml)

_Thredded_ is a Rails 7.0+ forum/messageboard engine. Its goal is to be as simple and feature rich as possible.

Some of the features currently in Thredded:

* Markdown (default) and / or BBCode post formatting, with [onebox] and `<spoiler>` / `[spoiler]` tag support.
* (Un)read posts tracking.
* Email notifications, topic subscriptions, @-mentions, per-messageboard notification settings.
* Private group messaging.
* Full-text search using the database.
* Pinned and locked topics.
* List of currently online users, for all forums and per-messageboard.
* Flexible permissions system.
* Basic moderation.
* Lightweight default theme configurable via Sass.

| ![Messageboards (Thredded v0.8.2)](https://cloud.githubusercontent.com/assets/216339/20338810/1fbc4240-abd1-11e6-9cba-4ae2e654c4d4.png) |  ![Topics (Thredded v0.8.2)](https://cloud.githubusercontent.com/assets/216339/20338809/1fbb7dc4-abd1-11e6-9bc3-207b94018931.png) |
|:---:|:---:|
| ![Topic on iPhone 6 (Thredded v0.8.2)](https://cloud.githubusercontent.com/assets/216339/20338433/0920debc-abcf-11e6-811c-8f29d10dfed7.png) | ![Messageboard Preferences on iPhone 6 (Thredded v0.8.2)](https://cloud.githubusercontent.com/assets/216339/20338432/090e9c5c-abcf-11e6-8e7e-e287d31f6a54.png) |

Thredded works with SQLite, MySQL (v5.6.4+), and PostgreSQL. Thredded has no infrastructure
dependencies other than the database and, if configured in the parent application, the ActiveJob
backend dependency such as Redis. Currently only MRI Ruby 3.1+ is supported. We would love to
support JRuby and Rubinius as well.

If you're looking for variations on a theme - see [Discourse]. However, it is a full rails
application and not an engine like Thredded.

[Discourse]: http://www.discourse.org/
[onebox]: https://github.com/discourse/onebox

Table of Contents
=================

* [Installation](#installation)
  * [Creating a new Rails app with Thredded](#creating-a-new-rails-app-with-thredded)
  * [Adding Thredded to an existing Rails app](#adding-thredded-to-an-existing-rails-app)
  * [Upgrading an existing install](#upgrading-an-existing-install)
  * [Migrating from Forem](#migrating-from-forem)
* [Rails compatibility](#rails-compatibility)
* [Views and other assets](#views-and-other-assets)
  * [Standalone layout](#standalone-layout)
  * [Application layout](#application-layout)
    * [Reference your paths so that Thredded can find them](#reference-your-paths-so-that-thredded-can-find-them)
    * [Add Thredded styles](#add-thredded-styles)
    * [Add Thredded JavaScripts (Sprockets)](#add-thredded-javascripts-sprockets)
    * [Add Thredded JavaScripts (Webpack)](#add-thredded-javascripts-webpack)
  * [User profile page](#user-profile-page)
  * [Customizing views](#customizing-views)
    * [View hooks](#view-hooks)
  * [Theming](#theming)
    * [Styles](#styles)
* [Email and other notifications](#email-and-other-notifications)
  * [Enabling auto-follow](#enabling-auto-follow)
* [I18n](#i18n)
* [Permissions](#permissions)
  * [Permission methods](#permission-methods)
    * [Reading messageboards](#reading-messageboards)
    * [Posting to messageboards](#posting-to-messageboards)
    * [Messaging other users (posting to private topics)](#messaging-other-users-posting-to-private-topics)
    * [Moderating messageboards](#moderating-messageboards)
    * [Admin permissions](#admin-permissions)
  * [Default permissions](#default-permissions)
  * [Handling "Permission denied" and "Not found" errors](#handling-permission-denied-and-not-found-errors)
* [Moderation](#moderation)
  * [Disabling moderation](#disabling-moderation)
* [Plugins](#plugins)
* [Development](#development)
  * [Testing](#testing)
  * [Ruby](#ruby)
  * [JavaScript](#javascript)
  * [Testing with all the databases and Rails versions locally.](#testing-with-all-the-databases-and-rails-versions-locally)
  * [Developing and Testing with Docker Compose](#developing-and-testing-with-docker-compose)


## Installation

### Creating a new Rails app with Thredded

> [!CAUTION]
> Please add thredded_create_app is currently out of date and needs contributors to fix it - it won't work with the latest thredded. See https://github.com/thredded/thredded_create_app if you can contribute.

<details>
<summary>
View the outdated instructions
</summary>

Thredded provides an app generator that will generate a Rails app with Thredded, Devise, SimpleForm, RSpec,
PostgreSQL, and a basic theme and navigation that is configured to work out of the box.

```sh
gem install thredded_create_app
thredded_create_app path/to/myapp
```

See `thredded_create_app --help` and the [thredded_create_app repo] to learn about the various options.

Then, see the rest of this Readme for more information about using and customizing Thredded.

[thredded_create_app repo]: https://github.com/thredded/thredded_create_app

</details>

### Adding Thredded to an existing Rails app

Add the gem to your Gemfile:

```ruby
gem 'thredded', '~> 1.2'
```

Add the Thredded [initializer] to your parent app by running the install generator.

```console
rails generate thredded:install
```

Thredded needs to know the base application User model name and certain columns on it. Configure
these in the initializer installed with the command above.

Then, copy the migrations over to your parent application and migrate:

```console
rake thredded:install:migrations db:migrate db:test:prepare
```

Mount the thredded engine in your routes file:

```ruby
mount Thredded::Engine => '/forum'
```

You also may want to add an index to the user name column in your users table.
Thredded uses it to find @-mentions and perform name prefix autocompletion on the private topic form.
Add the index in a migration like so:

```ruby
DbTextSearch::CaseInsensitive.add_index(
    connection, Thredded.user_class.table_name, Thredded.user_name_column, unique: true)
```

### Upgrading an existing install

1) To upgrade the initializer:

```console
rails g thredded:install
```

But then compare this with the previous version to decide what to keep.

2) To upgrade the database (in this example from v0.11 to v0.12):

```console
# Note that for guaranteed best results you will want to run this with the thredded gem at v0.12
cp "$(bundle show thredded)"/db/upgrade_migrations/20170420163138_upgrade_thredded_v0_11_to_v0_12.rb db/migrate
rake db:migrate
```

### Migrating from Forem

Are you currently using [Forem]? Thredded provides [a migration][forem-to-thredded] to copy all of your existing data from Forem over
to Thredded.

[forem-to-thredded]: https://github.com/thredded/thredded/wiki/Migrate-from-Forem
[Forem]: https://github.com/rubysherpas/forem

## Rails compatibility

| Rails                 | Latest Thredded |
|-----------------------|-----------------|
| Rails 7.0 - Rails 8.0 | Thredded 1.2    |
| Rails 6.1             | Thredded 1.1    |
| Rails 6.0             | Thredded 1.1    |
| Rails 5.2             | Thredded 1.0.1  |
| Rails 4.2             | Thredded 0.16.16 |


## Views and other assets

### Standalone layout

By default, thredded renders in its own (standalone) layout.

When using the standalone thredded layout, the log in / sign out links will be rendered in the navigation.
For these links (and only for these links), Thredded makes the assumption that you are using devise as your auth
library. If you are using something different you need to override the partial at
`app/views/thredded/shared/nav/_standalone.html.erb` and use the appropriate log in / sign out path URL helpers.

You can override the partial by copying it into your app:

```bash
mkdir -p app/views/thredded/shared/nav && cp "$(bundle show thredded)/$_/_standalone.html.erb" "$_"
```

### Application layout

You can also use Thredded with your application (or other) layout by setting `Thredded.layout` in the initializer.

In this case, you will need to reference your paths/routes carefully and pull in thredded assets (styles and javascript):

#### Reference your paths so that Thredded can find them

In your layout you will probably have links to other paths in your app (e.g. navigation links).
For any url helpers (like `users_path` or `projects_path` or whatever) will need to have `main_app.`
prefixed to them so that they can be found from thredded (`main_app.users_path` will work from both thredded and your app).

#### Add Thredded styles

In this case, you will also need to include Thredded styles and JavaScript into the application styles and JavaScript.

Add thredded styles to your `application.scss`:

```scss
@import "thredded";
```

Thredded wraps the views in a container element that has a `max-width` and paddings by default.
If your app layout already has a container element that handles these, you can remove the `max-width` and paddings
from the Thredded one by adding this Sass snippet after `@import "thredded";`:

```scss
.thredded--main-container {
  // The padding and max-width are handled by the app's container.
  max-width: none;
  padding: 0;
  @include thredded-media-tablet-and-up {
    padding: 0;
  }
}
```

See [below](#styles) for customizing the styles via Sass variables.

#### Add Thredded JavaScripts (Sprockets)

Include thredded JavaScripts in your `application.js`:

```js
//= require thredded
```

Thredded is fully compatible with deferred and async script loading.

#### Add Thredded JavaScripts (Webpack)

You can also include Thredded JavaScript into your webpack pack.

First, run `bundle exec rails webpacker:install:erb`.

Then, add an `app/javascript/thredded_imports.js.erb` file with the following contents:

```erb
<%= Thredded::WebpackAssets.javascripts %>
```

Finally, add the following to your `app/javascript/packs/application.js`:

```js
require('thredded_imports.js');
```

Note that you must use `require` (not `import`) because Thredded JavaScript must be run after UJS/Turbolink `start()`
has been called. This is because Webpack places `import` calls before the code in the same file (unlike `require`,
which are placed in the same order as in the source).

##### Alternative JavaScript dependencies

<details><summary><b>Rails UJS version</b></summary>

By default, thredded loads `rails-ujs`.

If you'd like it to use `jquery_ujs` instead, run this command from your app directory:

```bash
mkdir -p app/assets/javascripts/thredded/dependencies/
printf '//= require jquery3\n//= require jquery_ujs\n' > app/assets/javascripts/thredded/dependencies/ujs.js
```
</details>

<details><summary><b>Timeago version</b></summary>

By default, thredded loads `timeago.js`.

If you'd like to use `jquery.timeago` or `rails-timeago` instead, run this command from your app directory:

```bash
mkdir -p app/assets/javascripts/thredded/dependencies/
echo '//= require jquery.timeago' > app/assets/javascripts/thredded/dependencies/timeago.js
```

You will also need to adjust the `//= require` statements for timeago locales if your site is translated into multiple
languages. For `jquery.timeago`, these need to be require after `thredded/dependencies` but before `thredded/thredded`.
E.g. for Brazilian Portuguese with jquery.timeago:

 ```js
 //= require thredded/dependencies
 //= require locales/jquery.timeago.pt-br
 //= require thredded/thredded
 ```
</details>

#### Thredded page title and ID

Thredded views also provide two `content_tag`s available to yield - `:thredded_page_title` and `:thredded_page_id`.
The views within Thredded pass those up through to your layout if you would like to use them.

### User profile page

Thredded does not provide a user's profile page, but it provides a partial for rendering the user's recent posts
in your app's user profile page. Here is how you can render it in your app:

```erb
<%= Thredded::ApplicationController.render partial: 'thredded/users/posts', locals: {
      posts: Thredded.posts_page_view(scope: user.thredded_posts.order_newest_first.limit(5),
                                      current_user: current_user) } %>
```

The `user` above is the user whose posts are rendered, and `current_user` is the user viewing the posts or `nil`.
The policy scopes that limit the posts to the ones `current_user` can see are applied automatically.

The code above uses the `ApplicationController.render` method introduced in Rails 5. If you're using Rails 4,
you will need to add the [`backport_new_renderer`](https://github.com/brainopia/backport_new_renderer) gem to use it.

### Customizing views

You can also override any views and assets by placing them in the same path in your application as they are in the gem.
This uses the [standard Rails mechanism](http://guides.rubyonrails.org/engines.html#overriding-views) for overriding
engine views. For example, to copy the post view for customization:

```bash
# Copy the post view into the application to customize it:
mkdir -p app/views/thredded/posts && cp "$(bundle show thredded)/$_/_post.html.erb" "$_"
```

**NB:** Overriding the views like this means that on every update of the thredded gem you have to check that your
customizations are still compatible with the new version of thredded. This is difficult and error-prone.
Whenever possible, use the styles and i18n to customize Thredded to your needs.

#### View hooks

Thredded provides view hooks to customize the UI before/after/replacing individual components.

View hooks allow you to render anything in the thredded view context.
For example, to render a partial after the post content textarea, add the snippet below to
the `config/initializers/thredded.rb` initializer:

```ruby
Rails.application.config.to_prepare do
  Thredded.view_hooks.post_form.content_text_area.config.before do |form:, **args|
    # This is render in the Thredded view context, so all Thredded helpers and URLs are accessible here directly.
    render 'my/partial', form: form
  end
end
```

You can use the post content textarea hook to add things like wysiwyg/wymean editors, buttons, help links, help copy,
further customization for the textarea, etc.

To see the complete list of view hooks and their arguments, run:

```bash
grep view_hooks -R --include '*.html.erb' "$(bundle show thredded)"
```

### Theming

The engine comes by default with a light and effective implementation of the
views, styles, and javascript. Once you mount the engine you will be presented
with a "themed" version of thredded.

#### Styles

Thredded comes with a light Sass theme controlled by a handful of variables that can be found here:
https://github.com/thredded/thredded/blob/main/app/assets/stylesheets/thredded/base/_variables.scss.

To override the styles, override the variables *before* importing Thredded styles, e.g.:

```scss
// application.scss
$thredded-brand: #9c27b0;
@import "thredded";
```

If you are writing a Thredded plugin, import the [`thredded/base`][thredded-scss-base] Sass package instead.
The `base` package only defines variables, mixins, and %-placeholders, so it can be imported safely without producing
any duplicate CSS.

[thredded-scss-dependencies]: https://github.com/thredded/thredded/blob/main/app/assets/stylesheets/thredded/_dependencies.scss
[thredded-scss-base]: https://github.com/thredded/thredded/blob/main/app/assets/stylesheets/thredded/_base.scss

### Email and other notifications

Thredded sends several notification emails to the users. You can override in the same way as the views.
See [this page](https://github.com/thredded/thredded/wiki/Styling-email-content) on how to style the emails.

If you use [Rails Email Preview], you can include Thredded emails into the list of previews by adding
`Thredded::BaseMailerPreview.preview_classes` to the [Rails Email Preview] `preview_classes` config option.

[Rails Email Preview]: https://github.com/glebm/rails_email_preview

You can also turn off the email notifier totally, or add other notifiers (e.g. Pushover, possibly Slack) by adjusting
the `Thredded.notifiers` configuration in your initializer. See the default initializer for examples.

You must configure the address the email appears to be from (`Thredded.email_from`). This address is also used as the "To" address for both email notifcations, as all the recipients are on bcc.

### Enabling auto-follow

In some cases, you'll want all users to auto-follow new messageboard topics by default. This might be useful
for a team messageboard or a company announcements board, for example. To enable user auto-follow of new topics,
run the following migration(s):

```ruby
change_column_default :thredded_user_preferences, :auto_follow_topics, true
```

## I18n

Thredded is mostly internationalized. It is currently available in English, Brazilian Portuguese, Chinese (Simplified),
German, Polish, Italian, Russian, French, and Spanish.
We welcome PRs adding support for new languages.

Here are the steps to ensure the best support for your language if it isn't English:

1. Add `rails-i18n` and `kaminari-i18n` to your Gemfile.

2. Require the translations for timeago.js in your JavaScript. E.g. if you want to add German and Brazilian Portuguese:

   Sprockets:

   ```js
   //= require thredded/dependencies/timeago
   //= require timeago/locales/de
   //= require timeago/locales/pt_BR
   //= require thredded
   ```

   Webpack:

   ```erb
   <% timeago_root = File.join(Gem.loaded_specs['timeago_js'].full_gem_path, 'assets', 'javascripts') %>
   import "<%= File.join(timeago_root, 'timeago.js') %>";
   <%= %w[de pt_BR].map { |locale| %(import "#{File.join(timeago_root, "timeago/locales/#{locale}.js")}";) } * "\n" %>
   <%= Thredded::WebpackAssets.javascripts %>
   ```

   Note that it is important that timeago and its locales are required *before* Thredded.

3. To generate URL slugs for messageboards, categories, and topics with support for more language than English,
   you can use a gem like [babosa](https://github.com/norman/babosa).
   Add babosa to your Gemfile and uncomment the `Thredded.slugifier` proc for babosa in the initializer.

## Permissions

Thredded comes with a flexible permissions system that can be configured per messageboard/user.
It calls a handful of methods on the application `User` model to determine permissions for logged in users, and calls
the same methods on `Thredded:NullUser` to determine permissions for non-logged in users.

### Permission methods

The methods used by Thredded for determining the permissions are described below.

* To customize permissions for logged in users, override any of the methods below on your `User` model.
* To customize permissions for non-logged in users, override these methods on `Thredded::NullUser`.

#### Reading messageboards

1. A list of messageboards that a given user can read:

  ```ruby
  # @return [ActiveRecord::Relation] messageboards that the user can read
  thredded_can_read_messageboards
  ```
2. A list of users that can read a given list of messageboards:

  ```ruby
  # @param messageboards [Array<Thredded::Messageboard>]
  # @return [ActiveRecord::Relation] users that can read the given messageboards
  self.thredded_messageboards_readers(messageboards)
  ```

#### Posting to messageboards

A list of messageboards that a given user can post in.

  ```ruby
  # @return [ActiveRecord::Relation<Thredded::Messageboard>] messageboards that the user can post in
  thredded_can_write_messageboards
  ```

#### Messaging other users (posting to private topics)

A list of users a given user can message:

```ruby
# @return [ActiveRecord::Relation] the users this user can include in a private topic
thredded_can_message_users
```

#### Moderating messageboards

A list of messageboards that a given user can moderate:

  ```ruby
  # @return [ActiveRecord::Relation<Thredded::Messageboard>] messageboards that the user can moderate
  thredded_can_moderate_messageboards
  ```

#### Admin permissions

Includes all of the above for all messageboards:

```ruby
# @return [boolean] Whether this user has full admin rights on Thredded
thredded_admin?
```

### Default permissions

Below is an overview of the default permissions, with links to the implementations:

<table>
<thead>
  <tr>
    <th align="center"></th>
    <th align="center">Read</th>
    <th align="center">Post</th>
    <th align="center">Message</th>
    <th align="center">Moderate</th>
    <th align="center">Administrate</th>
  </tr>
</thead>
<tbody>
<tr>
  <th align="center">Logged in</th>
  <td align="center" rowspan="2"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/read/all.rb">
    ✅ All
  </a></td>
  <td align="center"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/write/all.rb">
    ✅ All
  </a></td>
  <td align="center"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/message/readers_of_writeable_boards.rb">
    Readers of the messageboards<br>the user can post in
  </a></td>
  <td align="center"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/moderate/if_moderator_column_true.rb">
    <code>moderator_column</code>
  </a></td>
  <td align="center"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/admin/if_admin_column_true.rb">
    <code>admin_column</code>
  </a></td>
</tr>
<tr>
  <th align="center">Not logged in</th>
  <!-- rowspan -->
  <td align="center"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/write/none.rb">
    ❌ No
  </a></td>
  <td align="center"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/message/readers_of_writeable_boards.rb">
    ❌ No
  </a></td>
  <td align="center"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/moderate/none.rb">
    ❌ No
  </a></td>
  <td align="center"><a href="https://github.com/thredded/thredded/blob/main/app/models/thredded/user_permissions/admin/none.rb">
    ❌ No
  </a></td>
</tr>
</tbody>
</table>

### Handling "Permission denied" and "Not found" errors

Thredded defines a number of Exception classes for not found / permission denied errors.
The complete list can be found [here](https://github.com/thredded/thredded/blob/main/app/controllers/thredded/application_controller.rb#L18-L40).

Currently, the default behaviour is to render an error message with an appropriate response code within the Thredded
layout. You may want to override the handling for `Thredded::Errors::LoginRequired` to render a login form instead.
For an example of how to do this, see the initializer.

## Moderation

Thredded comes with two options for the moderation system:

1. Reactive moderation, where posts from first-time users are published immediately but enter the moderation queue
   (default).
2. Pre-emptive moderation, where posts from first-time users are not published until they have been approved.

This is controlled by the `Thredded.content_visible_while_pending_moderation` setting.

Users, topics, and posts can be in one of three moderation states: `pending_moderation`, `approved`, and `blocked`.
By default, new users are `pending_moderation`, and new posts and topics inherit their default moderation_state from
the user's.

When you approve a new user's post, all of their later posts will be approved automatically.

Additionally, users always see their own posts regardless of the moderation state. For blocked users, this means
they might not realize they have been blocked right away.

Blocked users cannot send private messages.

### Disabling moderation

To disable moderation, e.g. if you run internal forums that do not need moderation, run the following migration:

```ruby
change_column_default :thredded_user_details, :moderation_state, 1 # approved
```

### Requiring authentication to access Thredded

To require users to be authenticated to access any part of Thredded, add the following to your initializer:

```ruby
# config/initializers/thredded.rb
Rails.application.config.to_prepare do
  Thredded::ApplicationController.module_eval do
    # Require authentication to access the forums:
    before_action :thredded_require_login!

    # You may also want to render a login form after the
    # "Please sign in first" message:
    rescue_from Thredded::Errors::LoginRequired do |exception|
      # Place the code for rendering the login form here, for example:
      flash.now[:notice] = exception.message
      controller = Users::SessionsController.new
      controller.request = request
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      controller.response = response
      controller.response_options = { status: :forbidden }
      controller.process(:new)
    end
  end
end
```

## Plugins

The following official plugins are available for Thredded:

* [BBCode](https://github.com/thredded/thredded-bbcode) formatting for posts, e.g. `[b]for bold[/b]`. Can be used alongside Markdown.
* [Code Syntax Highlighting in Markdown](https://github.com/thredded/thredded-markdown_coderay) using Coderay.
* [TeX math via KaTeX in Markdown](https://github.com/thredded/thredded-markdown_katex), fast, accessible, JS-free math rendering.

Thredded is built for extensibility, and writing plugins for it is easy. If you plan on extending Thredded functionality
in a way others may benefit from, please consider making it a plugin.

## Development

To be more clear - this is the for when you are working on *this* gem.
Not for when you are implementing it into your Rails app.

First, to get started, migrate and seed the database (SQLite by default):

```bash
bundle
# Create, migrate, and seed the development database with fake forum users, topics, and posts:
bin/rails db:create db:migrate db:seed
```

Install NPM dependencies for the dummy app:

```bash
cd spec/dummy && yarn && cd -
```

Then, start the dummy app server:

```bash
bin/rails s
```

By default, the dummy app server uses Webpack for JavaScript.
To use Sprockets instead, run:

```bash
THREDDED_TESTAPP_SPROCKETS=1 bin/rails s
```

alternatively you can use guard (which comes with activereload to make development more pleasant) with:

    export THREDDED_USE_GUARD=1
    bundle
    bundle exec guard


### Testing

In order to run the tests locally, you will need to be running webpack-dev-server (or do a manual compilation):

    cd spec/dummy && yarn && cd -
    BUNDLE_GEMFILE="${PWD}/Gemfile" spec/dummy/bin/webpack-dev-server

Then to run the tests, just run `rspec`. The test suite will re-create the test database on every run, so there is no need to
run tasks that maintain the test database.

By default, SQLite is used in development and test. On Travis, the tests will run using SQLite, PostgreSQL, MySQL,
and all the supported Rails versions.

The test suite requires Chromium v59+ and its WebDriver installed:

On Ubuntu, run:

```bash
sudo apt-get install chromium-chromedriver
```

On Mac, run:

```bash
brew install --cask chromium
brew install --cask chromedriver
```

To get better page saves (`page.save_and_open_page`) from local capybara specs ensure you are running the server locally
and set `export CAPYBARA_ASSET_HOST=http://localhost:3000` (or whatever host/port your server is on) before running your
test suite.

### Ruby

Thredded Ruby code formatting is ensured by [Rubocop](https://github.com/bbatsov/rubocop). Run `rubocop -a` to ensure a
consistent code style across the codebase.

Thredded is documented with [YARD](http://yardoc.org/) and you can use the
[inch gem](https://github.com/rrrene/inch) or the [Inch CI](http://inch-ci.org/github/thredded/thredded) to find code
that lacks documentation.

### JavaScript

Currently, Thredded JavaScript is written in the subset of ES6 that does not
require Babel polyfills. We're waiting for the ES6/7 support on Rails to improve
before updating this to full Babel.

All Thredded JavaScript is compatible with the following Turbolinks options:

* No Turbolinks.
* Turbolinks 5.
* Turbolinks Classic.
* Turbolinks Classic + jquery-turbolinks.

Thredded JavaScript is also compatible with being loaded from script elements with
`[async]` and/or `[defer]` attributes.

To achieve the above, all the Thredded code must register onload via
`Thredded.onPageLoad`, e.g.:

```js
window.Thredded.onPageLoad(() => {
  // Initialize widgets
  autosize('textarea');
});
```

Additionally, all the thredded views must be wrapped in a `<%= thredded_page do %>` block.

On Turbolinks 5 onPageLoad will run on the same DOM when the page is restored
from history (because Turbolinks 5 caches a *clone* of the body node, so
the events are lost).

This means that all DOM modifications on `window.Thredded.onPageLoad` must be
idempotent, or they must be reverted on the `turbolinks:before-cache` event,
e.g.:

```js
document.addEventListener('turbolinks:before-cache', () => {
  // Destroy widgets
  autosize.destroy('textarea');
});
```

### Testing with all the databases and Rails versions locally.

You can also test the gem with all the supported databases and Rails versions locally.

First install PostgreSQL and MySQL, and run:

```bash
script/create-db-users
```

Then, to test with all the databases and the default Rails version (as defined in `Gemfile`), run:

```bash
rake test_all_dbs
```

To test with a specific database and all the Rails versions, run:

```bash
# Test with SQLite3:
rake test_all_gemfiles
# Test with MySQL:
DB=mysql2 rake test_all_gemfiles
# Test with PostgreSQL:
DB=postgresql rake test_all_gemfiles
```

To test all combinations of supported databases and Rails versions, run:

```bash
rake test_all
```

### Developing and Testing with [Docker Compose](http://docs.docker.com/compose/)

To quickly try out _Thredded_ with the included dummy app, clone the source and
start the included docker-compose.yml file with:

```console
docker compose build
docker compose up
```

The above will build and run everything, daemonized, resulting in a running
instance on port 9292. Running `docker compose logs` will let you know when
everything is up and running. Editing the source on your host machine will
be reflected in the running docker'ized application.

You can run the test suite with the following (assuming you've already done `docker compose up`)

```console
docker compose exec web bundle exec rake
```

Alternatively you run a one-off dyno `docker compose run web bundle exec rake`

The docker container uses PostgreSQL

[initializer]: https://github.com/thredded/thredded/blob/main/lib/generators/thredded/install/templates/initializer.rb
