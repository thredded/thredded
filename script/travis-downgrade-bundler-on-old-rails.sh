#!/usr/bin/env bash

set -euo pipefail

# Rails 4.x requires bundler version < 2.0.
if [[ $BUNDLE_GEMFILE == "${PWD}/spec/gemfiles/rails_4_2.gemfile" ]]; then
  set -x
  find /home/travis/.rvm/rubies -wholename '*default/bundler-*.gemspec' -delete
  gem install bundler --version='~> 1.17'
  bundler --version
fi
