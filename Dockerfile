FROM ruby:2.2.2

RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev \
  libxml2-dev libxslt1-dev nodejs

WORKDIR /tmp
RUN mkdir -p /tmp/lib/thredded
ADD ./lib/thredded/version.rb /tmp/lib/thredded/
ADD thredded.gemspec /tmp/
ADD shared.gemfile /tmp/
ADD Gemfile /tmp/
RUN bundle install

ENV APP_HOME /thredded
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME
