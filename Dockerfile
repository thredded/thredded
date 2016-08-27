FROM alpine:3.4

RUN apk add --no-cache \
    # Runtime deps
    ruby ruby-bundler ruby-bigdecimal ruby-io-console tzdata nodejs bash \
    # Bundle install deps
    build-base ruby-dev libc-dev linux-headers gmp-dev openssl-dev libxml2-dev libxslt-dev \
    mariadb-dev postgresql-dev sqlite-dev

ENV BUNDLE_SILENCE_ROOT_WARNING=1

ENV APP_HOME /thredded
WORKDIR $APP_HOME
RUN mkdir -p $APP_HOME

# Copy Gemfile and run bundle install first to allow for caching
ADD ./lib/thredded/version.rb $APP_HOME/lib/thredded/
ADD thredded.gemspec shared.gemfile Gemfile $APP_HOME/
RUN bundle install

ADD Rakefile config.ru app/ bin/ config/ db/ lib/ script/ spec/ $APP_HOME/
