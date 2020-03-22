FROM alpine:3.11

RUN apk add --no-cache \
    # Runtime deps
    ruby ruby-bundler ruby-bigdecimal ruby-io-console ruby-json ruby-webrick tzdata nodejs yarn bash \
    # Bundle install deps
    build-base ruby-dev libc-dev libffi-dev linux-headers gmp-dev libressl-dev libxml2-dev libxslt-dev \
    mariadb-connector-c-dev postgresql-dev sqlite-dev git \
    # Testing deps
    chromium

RUN gem install foreman

ENV BUNDLE_SILENCE_ROOT_WARNING=1
ENV BUNDLE_PATH=/bundle
ENV DOCKER=1

ENV APP_HOME /thredded
WORKDIR $APP_HOME
RUN mkdir -p $APP_HOME/tmp/pids

# Copy Gemfile and run bundle install first to allow for caching
COPY ./lib/thredded/version.rb $APP_HOME/lib/thredded/
COPY thredded.gemspec shared.gemfile i18n-tasks.gemfile rubocop.gemfile Gemfile $APP_HOME/
RUN bundle --path=$BUNDLE_PATH -j $(nproc)

# Copy package.json and install dependencies (done here to allow for caching)
COPY ./spec/dummy/package.json $APP_HOME/spec/dummy/
RUN cd spec/dummy && yarn
