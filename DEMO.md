### Deploying the thredded demo to Heroku

To deploy:

    script/deploy-demo-app

By default this deploys the master branch (it has to create a temporary copy of a branch)

You need push access to the heroku app.

### Setup

The app has been set up with:

* Heroku postgres (hobby dev, free)
* Scheduler with `rake db:reseed`, at arbitrary times

and the following ENV:

    DB_POOL:                  15
    HEROKU:                   true
    RACK_ENV:                 production
    RAILS_ENV:                production
    RAILS_LOG_TO_STDOUT:      enabled
    RAILS_SERVE_STATIC_FILES: enabled

