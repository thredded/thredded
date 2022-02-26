The checklist for releasing a new version of Thredded.

Pre-requisites for the releaser:

* The [gem-release gem](https://github.com/svenfuchs/gem-release): `gem install gem-release`.
* Push access to the demo app Heroku.
* Push access to RubyGems.

Release checklist:

- [ ] Update gem version in `version.rb` and `README.md`.
- [ ] Update `CHANGELOG.md`. Ensure that the following links point to the future git tag for this version:
  * [ ] The "See the full list of changes here" link.
  * [ ] The migration link, if any.
- [ ] Wait for the Travis build to come back green.
- [ ] Tag the release and push it to rubygems:

  ```bash
  gem tag && gem release
  ```

  (alternatively if gem-release isn't installed you can use `rake release`)
- [ ] Copy the release notes from the changelog to [GitHub Releases](https://github.com/thredded/thredded/releases).
- [ ] Push the demo app to Heroku:

  ```bash
  script/deploy-demo-app
  ```

If this is a release with major new functionality, announce it:

- [ ] Publish a post on RubyFlow (e.g. like [this one for v0.5.0](http://www.rubyflow.com/p/7cpq63-thredded-v050)).
- [ ] Post an update to the [MetaRuby Thredded thread](https://metaruby.com/t/thredded-a-new-lightweight-forums-engine-for-rails/492/4).
- [ ] anywhere else you can think of

The announcements should contain all the major new functionality added to Thredded *since the previous announcement*
in that channel.
