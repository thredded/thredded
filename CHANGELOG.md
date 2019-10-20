# Unreleased

## Added

* Sprockets 4.0.0 support.
* Messageboard group page. Can be disabled by setting `Thredded.show_messageboard_group_page = false`.
  [#829](https://github.com/thredded/thredded/pull/829)

# v0.16.13

## Added

* Rails 6.0.0 support (6.0.0.rc2 no longer supported).
* Destroy Messageboard button in the UI for admins. Disabled by default.
  [#826](https://github.com/thredded/thredded/pull/826)

## Fixed

* Fixed `post_moderation_records` user reference type when using UUID.
  [#819](https://github.com/thredded/thredded/pull/819)

# v0.16.12

## Added

* Rails 6.0.0.rc2 support.
  [#824](https://github.com/thredded/thredded/pull/824)
* Improved moderation history performance.
  [a48a4726](https://github.com/thredded/thredded/commit/a48a47267cdc4ad099a372fdb7feea96d8195258)
  [f1874fba](https://github.com/thredded/thredded/commit/f1874fba333444255979c0789ba17f8dc24a4d6f)

# v0.16.11

## Fixed

* Table column alignment now works.
  [#804](https://github.com/thredded/thredded/issues/804)
* Improved `AutofollowUsers` performance.
  [#807](https://github.com/thredded/thredded/issues/807) [#808](https://github.com/thredded/thredded/pull/808)

# v0.16.10

## Added

* Rails 6 beta support.
  [#802](https://github.com/thredded/thredded/pull/802) [#800](https://github.com/thredded/thredded/pull/800)
* Thredded now adds the CSP nonce to inline script tags if CSP is enabled on Rails v5.2+.
  [#797](https://github.com/thredded/thredded/pull/797)

# v0.16.9

## Fixed

* Moderation > Pending now works again in Rails 4.
  [#794](https://github.com/thredded/thredded/issues/794)

* `@`-mentions are now parsed and highlighted using `Thredded.user_name_column` instead of `user.thredded_display_name`.
  [#790](https://github.com/thredded/thredded/issues/790)

# v0.16.8

## Fixed

* Unread followed topics navigation icon now correctly displays on mobile.
  [#791](https://github.com/thredded/thredded/issues/791)
  [8dc4e1a2](https://github.com/thredded/thredded/commit/8dc4e1a2dbb5697d91351d1bd586767e010104c0)

# v0.16.7

## Fixed

* Fix post order for moderation pending & activity (a regression introduced in v0.16.6).
  [cec880d8](https://github.com/thredded/thredded/commit/cec880d898ed0e35dda2e94de2e0e1bd09a1ce6d)

# v0.16.6

## Fixed

* N+1 queries moderation pending & activity.

  This also fixes ActiveRecord pool exhaustion caused by trying to obtain multiple database connections
  from the render threads.
  [#788](https://github.com/thredded/thredded/issues/788)

# v0.16.5

## Fixed

* Kramdown v2.0 support.
  [#786](https://github.com/thredded/thredded/issues/786)

# v0.16.4

## Changed

* Previously, Thredded issued a separate database query for @-mentions within each post when rendering a topic
  (at most 1 query per topic). Since posts are rendered in multiple threads by default, this wasn't as slow as
  you might expect. However, it still required a larger connection pool and could still be slow for topics with
  lots of @-mentions. Now, Thredded caches the @-mentioned users and the database query is under a mutex.
  This means Thredded no longer needs a large database connection pool ([#770](https://github.com/thredded/thredded/issues/770))
  and queries for repeated @-mentions across posts are avoided.

  [#771](https://github.com/thredded/thredded/issues/771)

# v0.16.3

Fixes private topic form preview (regression in v0.16.2).

# v0.16.2

## Added

* `mark_as_read` and `mark_as_unread` endpoints can now also respond to JSON.
  This is intended for plugins and user extensions.
  [#763](https://github.com/thredded/thredded/pull/763)

* A view hook for customizing topic title on `topics#show`.
  [#775](https://github.com/thredded/thredded/pull/775)

## Changed

* `mark_as_read` and `mark_as_unread` are now the `/action/` route path scope (and so will all the future actions).
  [#763](https://github.com/thredded/thredded/pull/763)

  Due to the new `/action` scope, if you have a Messageboard called "Action" you may need to change its slug:

  ```ruby
  Thredded::Messageboard.where(slug: 'action').each{|m| m.update(slug: 'action-messageboard')}
  ```

* Thredded now depends on [`sassc-rails`] instead of [`sass-rails`].
  [`sassc-rails`] uses [`sassc`], which is a wrapper for [`libsass`], a C++ implementation of Sass.
  This change was made because the Ruby implementation of Sass is now deprecated.
  [#736](https://github.com/thredded/thredded/pull/736)

* Improved pt-BR translation. Thanks @wenderjean! [#766](https://github.com/thredded/thredded/pull/766)

[`sassc-rails`]: https://github.com/sass/sassc-rails
[`sass-rails`]: https://github.com/rails/sass-rails
[`sassc`]: https://github.com/sass/sassc
[`libsass`]: https://github.com/sass/libsass

## Fixed

* Preview controller 500 error if the user was not signed in.
  [#780](https://github.com/thredded/thredded/pull/780) [#779](https://github.com/thredded/thredded/issues/779)

* Broken post content caching with Rails 5.2 framework defaults.
  [#769](https://github.com/thredded/thredded/pull/769) [#712](https://github.com/thredded/thredded/issues/712)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.16.1...v0.16.2.

# v0.16.1

## Added

* The unread icon now has the notifications bell.
  [#750](https://github.com/thredded/thredded/issues/750)
* You can now specify which page the user is redirected to after posting a topic.
  [#619](https://github.com/thredded/thredded/issues/619)
* Sass variables to customize messageboard title font size and topic header font size.
  [#740](https://github.com/thredded/thredded/pull/740)
* Topics and posts count now account for topic/post visibility. Please report performance issues.
  [#758](https://github.com/thredded/thredded/pull/758)

## Fixed

* Various issues with the recipients dropdown in Private Messages.
  [#722](https://github.com/thredded/thredded/issues/722)
  [#745](https://github.com/thredded/thredded/issues/745)
* User autocompletion now sorts correctly (case-insensitive lexicographic).
  [#744](https://github.com/thredded/thredded/issues/744)
* Fixed last post by displaying as "deleted user" when user primary key is a UUID.
  [#692](https://github.com/thredded/thredded/issues/692)
* The JavaScript code that eagerly marks topics as read for better Turbolinks back button experience now respects
  `Thredded.posts_per_page`. The unread+followed counter now also gets updated.
  [#755](https://github.com/thredded/thredded/issues/755)
  [#759](https://github.com/thredded/thredded/pull/759)
* No longer breaks if `main_app` ovverides `Kaminari.config.page_method_name`.
  [#741](https://github.com/thredded/thredded/issues/741)
* Messageboard grid now correctly sizes cells in incomplete rows up to 6 cells.
  [#754](https://github.com/thredded/thredded/pull/754)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.16.0...v0.16.1.

# v0.16.0

## Added

* Unread and unread followed topics are now indicated on the messageboards page like this:

  ![thredded-messageboards-unread](https://user-images.githubusercontent.com/216339/46279971-898d3600-c562-11e8-8366-7112569b849a.png)

  [#735](https://github.com/thredded/thredded/pull/735)

## Changed

* Thredded no longer provides emoji functionality such as `:smile:` by default, and also
  no longer depends on the `gemoji` gem. It is easy to add `gemoji` back in if you want to:

  1. Follow the installation instructions at https://github.com/github/gemoji.
  2. Add the following line to `config/initializers/thredded.rb`:

     ```ruby
     Thredded::ContentFormatter.after_markup_filters.insert(1, HTML::Pipeline::EmojiFilter)
     ```

  [#739](https://github.com/thredded/thredded/pull/739)

**NB**: If updating to this version from 0.15.x, you **must** copy and run the upgrade migration after updating the gem:

```console
cp "$(bundle show thredded)"/db/upgrade_migrations/20180930063614_upgrade_thredded_v0_15_to_v0_16.rb db/migrate
bin/rails db:migrate
```

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.15.5...v0.16.0.

# v0.15.5

## Changed

* Performance improvement: Avoid redundant permission queries.
[#725](https://github.com/thredded/thredded/pull/725)

## Fixed

* Navigate to the correct page for read topics.
  [f5237960](https://github.com/thredded/thredded/commit/f5237960911d647171c8f362fcca3f53896a1778)
* Fix an error when approving / blocking a post that was already approved / blocked.
  [#723](https://github.com/thredded/thredded/issues/723)
* When creating a messageboard, show an error message if the name is too long. Also makes the valid name length range
  configurable.
  [#720](https://github.com/thredded/thredded/issues/720)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.15.4...v0.15.5.

# v0.15.4

## Added

* A new helper method to start a private thread between two users, `Thredded::UrlsHelper.send_private_message_path`.
  If a thread already exists between the two users, returns the URL to that thread. Otherwise, returns a URL to the new
  message form with the recipient and subject pre-filled.
  [#716](https://github.com/thredded/thredded/pull/716)
* Posts and topics can now be submitted with the <kbd>Ctrl</kbd>+<kbd>Return</kbd> shortcut.
  [#717](https://github.com/thredded/thredded/pull/717)
* The number of posts / topics per page is now configurable via `Thredded.posts_per_page` and `Thredded.topics_per_page`.
  [#711](https://github.com/thredded/thredded/issues/711)
* For each topic on the Unread page, we now show the topic's messageboard.
  [ed862031](https://github.com/thredded/thredded/commit/ed862031fa1f8d65c50439aeb578d9b0a8cd7be2)
* `Thredded::Errors::(Private)PostNotFound` is raised and handled instead of `ActiveRecord::NotFound`.
  [#513](https://github.com/thredded/thredded/issues/513)

## Changed

* The default number of posts per page has been reduced to 25.
  [#713](https://github.com/thredded/thredded/pull/713)
* Updated bundled JavaScript dependencies:
  `autosize` from v4.0.0 to v4.0.2
  ([9c4db86d](https://github.com/thredded/thredded/commit/9c4db86dfbfc37ef2df8530bc4392dc3e910d169)),
  `textcomplete` from v0.14.5 to v0.17.1
  ([211ce25a](https://github.com/thredded/thredded/commit/211ce25a607893395f1b45e1fe6c5c8b2a7cdf27)).

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.15.3...v0.15.4.

# v0.15.3

## Fixed

* Minor style issues and regressions introduced in v0.15.2.

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.15.2...v0.15.3.

# v0.15.2

## Added

* Adds a global / messageboard-level unread page. Topics are ordered followed-first. The navigation link has a badge
  indicating the numbers of followed unread topics. If there are no unread topics at all (including non-followed ones),
  the link is not displayed.
  [#709](https://github.com/thredded/thredded/pull/709)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.15.1...v0.15.2.

# v0.15.1

## Fixed

* Regression in v0.15.0: broken `Thredded.posts_page_view`.

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.15.0...v0.15.1.

# v0.15.0

## Added

* Spoiler tags via `<spoiler></spoiler>` (or `[spoiler][/spoiler]` with the BBCode plugin).
  Supported out of the box for any markup processor.
  Spoilers are focusable and are activated on mousedown, spacebar, or enter. They can also be nested.
  Markup is configurable via `Thredded::SpoilerTagFilter.spoiler_tags`.
  [#701](https://github.com/thredded/thredded/pull/701)
* Jump to the first unread post when navigating to a topic.
  [#695](https://github.com/thredded/thredded/pull/695)

## Fixed

* Fixes a race condition when setting `last_seen_at` for the user.
  [#674](https://github.com/thredded/thredded/pull/674)
* Moves validation of topic title lengths from the database into Rails and shows the error messages on title.
  The valid length range is configurable via the new `Thredded.topic_title_length_range` configuration option.
  [#703](https://github.com/thredded/thredded/pull/703)

## Changed

* Post IP tracking removed from core because it requires explicit consent under GDPR.
  [#705](https://github.com/thredded/thredded/pull/705)

**NB**: If updating to this version from 0.14.x, you **must** copy and run the upgrade migration after updating the gem:

```console
cp "$(bundle show thredded)"/db/upgrade_migrations/20180110200009_upgrade_thredded_v0_14_to_v0_15.rb db/migrate
rake db:migrate
```

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.14.5...v0.15.0.

# v0.14.5

## Added

* Improved performance of rendering threads with multiple onebox by rendering the posts concurrently.
  [#696](https://github.com/thredded/thredded/pull/696)
* Private topic parameters can now be pre-filled from URL.
  [#b107e65c](https://github.com/thredded/thredded/commit/b107e65c404b52fd31fe91e90137417047929066)

  A "Send private message" link can now be generated like this:

  ```ruby
  new_private_topic_path(private_topic: { user_names: 'glebm' })
  ```

## Fixed

* Now handles pages beyond the last one by issuing a redirect to the last page.
  [#4a43b1e3](https://github.com/thredded/thredded/commit/4a43b1e3be854480fcbba1e9a110786d49e4ddbd)

# v0.14.4

## Added

* Usernames in the "Currently Online" list are now links leading to the users' profiles.

## Fixed

* Fixes an error when saving global notification preferences.
  [#9bc0e815](https://github.com/thredded/thredded/commit/9bc0e81566a54534214ddf5a8713aafae7b017d9)

# v0.14.3

## Fixed

* Accidental N+1 query in `AutofollowUsers` job.
  [#690](https://github.com/thredded/thredded/pull/690)

* Some French translations.
  [#681](https://github.com/thredded/thredded/pull/681)

* Onebox errors resulting in 500 response.
  [#683](https://github.com/thredded/thredded/pull/683)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.14.2...v0.14.3.

# v0.14.2

## Added

* Rails 5.2 support.
* User's display name (via `Thredded.user_display_name_method`) is now displayed in autocomplete results
  if it is different from the user name (`Thredded.user_name_column`).
  [#680](https://github.com/thredded/thredded/pull/680)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.14.1...v0.14.2.

# v0.14.1

## Added

* Italian localization. 🇮🇹
  [#669](https://github.com/thredded/thredded/pull/669)
* Allow disabling user links.
  [#673](https://github.com/thredded/thredded/pull/673)
* Allow customizing first messageboard post.
  [#670](https://github.com/thredded/thredded/pull/670)

## Fixed

* A minor JavaScript error on the topic edit form.
  [#be45f262](https://github.com/thredded/thredded/commit/be45f2627ca37c76165d33fad0118a87139f291b)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.14.0...v0.14.1.

# v0.14.0

## Added

* Messageboard locking. By default, only moderators can create new topics in locked messageboards.
  Posting to the existing topics is not affected.
  [#635](https://github.com/thredded/thredded/pull/635)

* German localization. 🇩🇪
  [#666](https://github.com/thredded/thredded/pull/666)

## Fixed

* `thredded_user_details` and `thredded_user_preferences` now use unique `user_id` indices.
  [#609](https://github.com/thredded/thredded/pull/609)
* Mention completion now works in IE11.
  [yuku-t/textcomplete#125](https://github.com/yuku-t/textcomplete/pull/125)


**NB:** If updating to this version from 0.13.x, you must copy and run the upgrade migration after updating the gem:

```console
cp "$(bundle show thredded)"/db/upgrade_migrations/20170811090735_upgrade_thredded_v0_13_to_v_014.rb db/migrate
rake db:migrate
```

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.13.8...v0.14.0.

# v0.13.8

## Fixed

* Made @-mention dropdown work properly with usernames with no spaces.
  [#645](https://github.com/thredded/thredded/pull/645)
* Other @-mention dropdown improvements (update to latest textcomplete)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.13.7...v0.13.8.

# v0.13.7

## Added

* Simplified Chinese localization. 🇨🇳
  [#632](https://github.com/thredded/thredded/pull/632)

# v0.13.6

## Fixed

* Private posts can be edited again.

## Added

* Locked topics have a different badge color in the topics list.
  Locked topics also display a message saying that they are locked.
  [#629](https://github.com/thredded/thredded/pull/629)

# v0.13.5

## Fixed

* timeago.js with locales that contain a hyphen (e.g. `zh-CN`).
  [#626](https://github.com/thredded/thredded/issues/626)

## Changed

* Post notification email subject no longer contains the post's author name.
  Notification emails for the same topic now stay in the same thread in the email client.
  [#90c6f5ff](https://github.com/thredded/thredded/commit/90c6f5fffd42ec1001c39dceb5ab5e875a71869d)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.13.4...v0.13.5.

# v0.13.4

## Added

* CSS classes for targeting specific preference list items.
  [#614](https://github.com/thredded/thredded/pull/614)

## Fixed

* Sticky topics in search results no longer break search results.
  [#611](https://github.com/thredded/thredded/issues/611)
* If a user was subscribed to a topic via more than one notifier,
  they would only be notified via one of them.
  [#540](https://github.com/thredded/thredded/issues/540)

# v0.13.3

## Added

* French localization :fr:.
  [#605](https://github.com/thredded/thredded/pull/605)
* Email templates now use i18n throughout. The copy has been improved.
  [#607](https://github.com/thredded/thredded/pull/607)

## Changed

* Avatars are now larger on large screens.
  [#565](https://github.com/thredded/thredded/issues/565)

# v0.13.2

This release updates the bundled JavaScript dependencies, [autosize] and [textcomplete], to their latest versions.

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.13.1...v0.13.2.

# v0.13.1

This is a minor bugfix release.

## Fixed

* Maps onebox display for onebox v1.8.4+ and bumps the minimum required onebox version to v1.8.13.
  [#198dbeeb](https://github.com/thredded/thredded/commit/198dbeebf32c509db0afb65c33293394581defd9)
* Autoloading conflicts when the parent app defines constants with the same name as Thredded constants.
  [#e2ebb1e4](https://github.com/thredded/thredded/commit/e2ebb1e418894c65f8b884821e2d7be085af3715)

# v0.13.0

This release removes jQuery dependency from Thredded JavaScripts, reducing the size of the Thredded JavaScript bundle
from 67 KiB to 22 KiB gzipped.

## Changed

* rails-ujs is used instead of jquery_ujs by default. [#592](https://github.com/thredded/thredded/pull/592)
  See the [README](https://github.com/thredded/thredded/#rails-ujs-version) for more information.
* select2 -> [textcomplete], split by commas.
  [#597](https://github.com/thredded/thredded/pull/597)
* [jquery.textcomplete] -> [textcomplete] [#596](https://github.com/thredded/thredded/pull/596)
* jquery.timeago -> timeago.js [#591](https://github.com/thredded/thredded/pull/591)

[jquery.textcomplete]: https://github.com/yuku-t/jquery-textcomplete
[textcomplete]: https://github.com/yuku-t/textcomplete

# v0.12.4

This release adds the ability to tell Thredded with version of Rails UJS to use.
Since Rails v5.1, the default is `rails-ujs` but Thredded for now still uses `jquery_ujs` by default.
This will change in Thredded v0.13.

If you'd like to tell Thredded to use `rails-ujs` now, update to this release and run the following command
from your app directory:

```bash
mkdir -p app/assets/javascripts/thredded/dependencies/
echo '//= require rails-ujs' > app/assets/javascripts/thredded/dependencies/ujs.js
```

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.12.3...v0.12.4.

# v0.12.3

This release adds a minor fix for Rails 5.1 compatibility.
[#b5669c61](https://github.com/thredded/thredded/commit/b5669c61173621298480f3f0d954a3083b672a80)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.12.2...v0.12.3.

# v0.12.2

This release brings Rails 5.1 support to Thredded.

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.12.1...v0.12.2.

# v0.12.1

The quote action now only appears on the topic page (and not in moderation, user's posts, etc).
[#fc960483](https://github.com/thredded/thredded/commit/fc96048399d5aa60fcea5b24ddedf4a4853fcc69)

This is the only the change in this release.

# v0.12.0

## Changed

* Topic slugs are now unique across messageboards.
  This allows us to correctly redirect to the new topic URL when the topic's messageboard has changed.
  [#573](https://github.com/thredded/thredded/issues/573)
  [#576](https://github.com/thredded/thredded/pull/576)

## Added

* Basic "Quote" reply action.
  [#585](https://github.com/thredded/thredded/pull/585)
* Navigation to individual messageboard settings from the global settings page.
  [#581](https://github.com/thredded/thredded/pull/581)

## Fixed

* Private topics page for blocked users.
  [#3a4d7032](https://github.com/thredded/thredded/commit/3a4d70323818f36405de32964d1782aaadfaa088)
* Support for Turbolinks v5.0.1 and the upcoming v5.1.0.
  [#25269979](https://github.com/thredded/thredded/commit/2526997965f818defd37522b05e7fa58814db96f)

## Internals

* The unmaintained `autosize-rails` gem replaced with a vendored version of
  [jackmoore/autosize](https://github.com/jackmoore/autosize).
  [#1023c215](https://github.com/thredded/thredded/commit/1023c21598575d51f8cd4448251f447c47cefa8f)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.11.1...v0.12.0.

---

**NB:** If updating to this version from 0.11.x, you must copy and run the upgrade migration after updating the gem:

```console
cp "$(bundle show thredded)"/db/upgrade_migrations/20170420163138_upgrade_thredded_v0_11_to_v0_12.rb db/migrate
rake db:migrate
```

# v0.11.1

## Changed

* User navigation is now shown on the right, and search is on the left.
  [#563](https://github.com/thredded/thredded/pull/563)
* On desktop screen sizes, messageboard breadcrumbs are no longer bold.
  [#574](https://github.com/thredded/thredded/pull/574)

## Added

* Sanitization defaults now allow `<abbr>` and a few ARIA attributes.
  [#2d29ef21](https://github.com/thredded/thredded/commit/2d29ef21c219e7aeefea6eefe121e636c6867240)
  [#df38d9e4](https://github.com/thredded/thredded/commit/df38d9e42bad31737d996da32788c0bd7ac6d04b)
* Kramdown options can now be passed to the ContentFormatter.
  [#c25d8765](https://github.com/thredded/thredded/commit/c25d876510588f8f4a5383385234ca5b2193e597)

## Fixed

* Topic URLs that use old slugs are now redirected to the current version.
  [#564](https://github.com/thredded/thredded/pull/564)
* PostPolicy no longer allows anonymous users to edit posts of deleted users.
  [#092d40b5](https://github.com/thredded/thredded/commit/092d40b5d2316eac04522333811eba7b122902f4)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.11.0...v0.11.1.

---

**NB:** If updating to this version from 0.10.x, you must copy and run the upgrade migration after updating the gem:

```console
cp "$(bundle show thredded)"/db/upgrade_migrations/20170312131417_upgrade_thredded_v0_10_to_v0_11.rb db/migrate
rake db:migrate
```

# v0.11.0

## Added

* **Oneboxes**: URLs to supported resources placed on their own line are replaced with a "onebox".
  Oneboxes replace the previous YouTube and Vimeo implementations and add support for dozens more sites, including
  Tweets, Google Maps, and so on. The implementation is powered by the [onebox](https://github.com/discourse/onebox)
  gem.
  [#545](https://github.com/thredded/thredded/issues/545)

* **Email styles**: the emails now come in style.
  See the [wiki article](https://github.com/thredded/thredded/wiki/Styling-email-content) on how to enable
  the email styles. In the emails, interactive content (such as Google Maps, YouTube Videos) is shown as a static
  image.
  [#550](https://github.com/thredded/thredded/pull/550)

* **Auto-follow all new topics setting**.
  [#488](https://github.com/thredded/thredded/issues/488) [#554](https://github.com/thredded/thredded/pull/554)

* Russian translation.
  [#556](https://github.com/thredded/thredded/pull/556)

## Fixed

Minor UI fixes throughout.

## Internals

* Removed the now-redundant `thredded_post_notifications` table.
  [#547](https://github.com/thredded/thredded/pull/547)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.10.1...v0.11.0.

# v0.10.1

## Changed

* Post actions moved to a dropdown menu.
  [#533](https://github.com/thredded/thredded/pull/533)

## Added

* Posts can be marked as unread.
  [#533](https://github.com/thredded/thredded/pull/533)
* More Sass variables for style customization:
  * `$thredded-messageboards-grid-item-border-(width|color)`
  * `$thredded-messageboards-grid-item-(padding|gutter)-(x|y)`
  * `$thredded-overlay-(background-color|box-shadow)`

* Support PostgreSQL UUID primary keys.
  [#538](https://github.com/thredded/thredded/issues/538)
* A divider line between sticky and non-sticky topic.
  [#537](https://github.com/thredded/thredded/pull/537)

## Fixed

* Various minor style issues.
  [#0631f46](https://github.com/thredded/thredded/commit/0631f461b7456b57239d2d8360abb06a06d19ff0)
  [#f341135](https://github.com/thredded/thredded/commit/f341135ad07beb8ac6e62c99293faefea1b052f9)
  [#3387cfc](https://github.com/thredded/thredded/commit/3387cfced6cbad1f59e8d5b045623c754693c21f)
  [#deb6ec8](https://github.com/thredded/thredded/commit/deb6ec876a5c474fc6575ce5852ddf25aa54569b)
  [#430dedb](https://github.com/thredded/thredded/commit/430dedbf0733304eb912bfa8d2ceca15a0760951)

## Internals

* Thredded now caches only the posts' contents (and not the UI around them).
  [#536](https://github.com/thredded/thredded/pull/536)
* The `Thredded::ApplicationController#signed_in?` method has been renamed to `thredded_signed_in?`,
  to avoid conflicts with the parent (application) controller.
  [#543](https://github.com/thredded/thredded/pull/543)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.10.0...v0.10.1.

# v0.10.0

## Changed

* Improved messageboards index layout.
  [#525](https://github.com/thredded/thredded/pull/525)
* Text contrast increased in the default theme to improve legibility.
  [#fd6cd6](https://github.com/thredded/thredded/commit/fd6cd694d4b513ad3fa031b3da7bc1df8fca0ef5)

## Added

* A user with permissions to edit a topic can now move the topic to another messageboard.
  [#530](https://github.com/thredded/thredded/pull/530)
* More view hooks for the messageboards index page.
  [#520](https://github.com/thredded/thredded/pull/520)

## Fixed

* Foreign key constraints that were preventing messageboard deletion on Postgres.
  [#526](https://github.com/thredded/thredded/issues/526)
* Issues with notifications: lack of policy checking and sending a notification more than once per a post and a user.
  [#529](https://github.com/thredded/thredded/issues/529)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.9.4...v0.10.0.

# v0.9.4

## Added

* Preview posts as yout type.
  [#237](https://github.com/thredded/thredded/issues/237)
* Polish localization.
  [#519](https://github.com/thredded/thredded/pull/519)
* Pagination on top of the topic page as well as the bottom by default.
  [#501](https://github.com/thredded/thredded/pull/501)
* KaTeX server-side TeX math rendering plugin.
  [#476](https://github.com/thredded/thredded/issues/476)

## Fixed

* Private message notification mailer now correctly shows the relevant message
  (previously it always showed the first message of the private topic).
  Also, improved the email copy.
  [#512](https://github.com/thredded/thredded/issues/512)
* @-mentions now allow and autocomplete `.` when quoted, e.g. `@"Mr. Smith"`.
  [#296773](https://github.com/thredded/thredded/commit/296773839b6931b7168202d663dbc3a007dbf84e)
* Fixed a breadcrumb URL on the topic page.
  [#9b5525](https://github.com/thredded/thredded/commit/9b55253f776d154692bed80da6507595631f86c6)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.9.3...v0.9.4.

# v0.9.3

This release brings Rails 5.0.1 compatibility to Thredded.

## Changed

* The Gemoji gem now locked to `~> 2.1.0` due to v3 removing most of the emoji, until we find a better solution.
  https://github.com/github/gemoji/releases/tag/v3.0.0.rc1

## Fixed

* Rails v5.0.1 compatibility. [#508](https://github.com/thredded/thredded/pull/508)
* Fix "Mark all as read button" overflowing on mobile.
  [#05089b](https://github.com/thredded/thredded/commit/05089b034f24e5efea30f71fef04c46cf9067e30)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.9.2...v0.9.3.

# v0.9.2

This release adds Spanish localization [#498](https://github.com/thredded/thredded/pull/498), and fixes
the installation on MySQL < v5.7.
[#925816](https://github.com/thredded/thredded/commit/9258164407884328efccb798e276f296439bc3f7)

# v0.9.1

This release contains new functionality and backwards-incompatible changes.

**NB:** If updating to this version from 0.8.x, you will need to copy and run [this migration](https://github.com/thredded/thredded/blob/v0.9.1/db/upgrade_migrations/20161113161801_upgrade_v0_8_to_v0_9.rb) after upgrading the gem.

## Added

* Notification plugins system. You can configure which notifiers are enabled: remove the email notifier totally,
  or add other notifiers (e.g. Pushover, possibly Slack) by adjusting the `Thredded.notifiers` configuration in
  your initializer. See the default initializer for examples.
  [#441](https://github.com/thredded/thredded/issues/441)
* Private topic participants are now displayed on both the "Private Messages" pages and the private topic page.
  [#477](https://github.com/thredded/thredded/issues/477)
* Buttons in forms are disabled on submit to prevent double-submits.
  [#485](https://github.com/thredded/thredded/pull/485)
* It is now possible to turn off automatic topic subscription on topic creation and when posting into an existing topic.
  [#372](https://github.com/thredded/thredded/issues/372)
* Minor front-end performance improvements.
  [#489](https://github.com/thredded/thredded/issues/489)
  [#6a2355](https://github.com/thredded/thredded/commit/6a235595f64d90422bc529fd260ce46a8832616b)
  [#ccc49f](https://github.com/thredded/thredded/commit/ccc49fd07019bdcea5b263d3fb7bf098a353cbfb)

## Changed

* Topic posts pagination is now displayed *before* the post form, making it obvious to the user if there are more posts.
  [#491](https://github.com/thredded/thredded/issues/491)
* Removed `Topic.find_by_slug` and `PrivateTopic.find_by_slug` methods.
  Added `friendly_find!` to `Messageboard`, `Topic`, and `PrivateTopic` instead to avoid confusion with the Rails
  dynamic finders.
  [#482](https://github.com/thredded/thredded/pull/482)

## Fixed

* Video embeds and other iframes in the posts contents are now responsive (16-by-9 ratio by default).
  [#493](https://github.com/thredded/thredded/issues/493)
* The "Mark all as read" button in private messages is no longer shown when there are unread messages.
  [#38c7a7](https://github.com/thredded/thredded/commit/38c7a70d3cf897ebae41ff93e967bbef2036a270)
* Fixed an SQLite3 compatibility issue that resulted in the `database is locked` error.
  [#37ad93](https://github.com/thredded/thredded/commit/37ad930bd28d9d8e5c89bba64a28a100b1cfde18)

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.8.4...v0.9.1.

# v0.8.4

This is a minor bugfix release.

## Fixed

* Compatibility with rails_admin.
  [#280](https://github.com/thredded/thredded/issues/280)
* Missing localization form the "Create New Topic" button and "Locked" and "Sticky" options.
  [#395](https://github.com/thredded/thredded/issues/395)
* Missing `require 'thredded/version'`.
  [#480](https://github.com/thredded/thredded/issues/480)

# v0.8.2

This is a hot-fix release, as v0.8.0 was broken.

## Fixed

* `vendor/assets/javascripts/jquery.textcomplete` was not packaged with the gem.
[57ed37](https://github.com/thredded/thredded/commit/57ed3790a99ea164e128ee99e3048f33b9e9eb18)

# v0.8.0

This release contains new functionality and backwards-incompatible changes.

See in particular "main app delegator" in Changed below.

**NB:** If updating to this version from 0.7.x, you will need to copy and run [this migration](https://github.com/thredded/thredded/blob/b73154b0b9e1ab0efd0ac1e9883bad902af1f1ec/db/upgrade_migrations/20161019150201_upgrade_v0_7_to_v0_8.rb) after upgrading the gem.

## Added

* The email notifications on mention setting has been split into two:

  1. Follow topics on mention.
  2. Send email notifications on updates to followed topics.

  [#427](https://github.com/thredded/thredded/pull/427)

* Autocompletion for @-mentions within post textarea.
  [#325](https://github.com/thredded/thredded/issues/325)
* Turbolinks 5 support. Turbolinks Classic with or without jQuery.Turbolinks are also supported.
  [#440](https://github.com/thredded/thredded/pull/440)
* Support for loading Thredded JavaScript via a script tag with `[async]` and/or `[defer]` attributes.
  [on_page_load.es6 @96090d](https://github.com/thredded/thredded/blob/b73154b0b9e1ab0efd0ac1e9883bad902af1f1ec/app/assets/javascripts/thredded/core/on_page_load.es6)
* View hooks have been added to enable your app and plugins to easily extend Thredded views (experimental).
  [#455](https://github.com/thredded/thredded/pull/455)

## Changed

* Thredded now loads jQuery v3 by default. If you load jQuery v1 or v2 in your app, you will need to tell Thredded to
  load the same version. [#469](https://github.com/thredded/thredded/pull/469) 
* BBCode support is no longer enabled by default and is now available via
  the [thredded-bbcode](https://github.com/thredded/thredded-bbcode) gem.
  [#460](https://github.com/thredded/thredded/issues/460)
* The "main app delegator" has been removed. If you are using an application layout for thredded, you need to either
  prefix your links with main_app or add some code to your thredded initializer
  [Readme on application layouts](https://github.com/thredded/thredded/blob/master/README.md#application-layout).
  [#420](https://github.com/thredded/thredded/pull/420)
* Content formatting filters have been split into groups based on what they process to make customizing them simpler.
  [#462](https://github.com/thredded/thredded/pull/462)
* The default markdown parser has been changed from the unmaintained and unsupported github-markdown gem to Kramdown.
  [#458](https://github.com/thredded/thredded/pull/458)
* Removed the `messageboards.closed` that was used for soft (aka logical) deletion. If you use soft deletion,
  consider using the [paranoia](https://github.com/rubysherpas/paranoia) gem instead.
  [#471](https://github.com/thredded/thredded/pull/471)

## Fixed

* Multiple UX issues, including:
  * Navigation icons and paddings on mobile.
  * Following icons in topics and the topic view.
    [#438](https://github.com/thredded/thredded/pull/438) [#448](https://github.com/thredded/thredded/pull/448)
  * Clicking on an already active tab in navigation now takes the user back to the messageboard(s).
* The "Mark all as read" button in private messages is no longer shown when there are no messages at all.
  [4b6c2f](https://github.com/thredded/thredded/commit/4b6c2f1664d9b39c9d797853e92cd361b2ebd8ec)
* The (un)follow endpoint now supports GET requests to enable redirect_back to it after sign in.
  [#435](https://github.com/thredded/thredded/pull/435)
* Messageboards `name` limit on MySQL was too long for a unique index with the `utf8mb4` encoding.
  [#432](https://github.com/thredded/thredded/pull/432)
* Minimum username autocomplete length is now configurable, resolving
  [#328 - support for 1-character usernames](https://github.com/thredded/thredded/issues/353).

See the full list of changes here: https://github.com/thredded/thredded/compare/v0.7.0...v0.8.0.

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
