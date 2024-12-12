FROM alpine:3.20

RUN apk add --no-cache \
    # Runtime deps
    ruby ruby-bundler ruby-bigdecimal ruby-io-console ruby-json ruby-webrick tzdata yarn bash \
    # Bundle install deps
    build-base ruby-dev libc-dev libffi-dev linux-headers gmp-dev libxml2-dev libxslt-dev \
    mariadb-connector-c-dev postgresql-dev sqlite-dev git yaml-dev \
    musl-dev make \
    # Testing deps
    chromium

# Compatible with dependencies in spec/dummy/package.json
ENV NODE_VERSION=14.21.3
RUN wget -q https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64-musl.tar.gz && \
    tar -xzf node-v$NODE_VERSION-linux-x64-musl.tar.gz -C /usr/local --strip-components=1 && \
    rm node-v$NODE_VERSION-linux-x64-musl.tar.gz && \
    ln -sf /usr/local/bin/node /usr/bin/node && \
    ln -sf /usr/local/bin/npm /usr/bin/npm && \
    ln -sf /usr/local/bin/npx /usr/bin/npx

RUN gem update --system
RUN gem install foreman

ENV BUNDLE_SILENCE_ROOT_WARNING=1
ENV BUNDLE_PATH=/bundle
ENV DOCKER=1

ENV APP_HOME=/thredded
WORKDIR $APP_HOME
RUN mkdir -p $APP_HOME/tmp/pids

# Copy Gemfile and run bundle install first to allow for caching
COPY ./lib/thredded/version.rb $APP_HOME/lib/thredded/
COPY ./spec/gemfiles $APP_HOME/spec/gemfiles/
COPY thredded.gemspec shared.gemfile i18n-tasks.gemfile rubocop.gemfile Gemfile $APP_HOME/
COPY ./spec/gemfiles/ $APP_HOME/spec/gemfiles/
RUN bundle --path=$BUNDLE_PATH -j $(nproc)

# Copy package.json and install dependencies (done here to allow for caching)
COPY ./spec/dummy/package.json $APP_HOME/spec/dummy/
RUN cd spec/dummy && yarn
