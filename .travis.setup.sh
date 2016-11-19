#!/usr/bin/env bash

# TODO: remove this once travis gets on with times and upgrades MySQL to 5.6.4+
if [ "$DB" = 'mysql2' ]; then
  sudo -E apt-get -yq update &>> ~/apt-get-update.log
  sudo -E apt-get -yq --no-install-suggests --no-install-recommends --force-yes install \
    mysql-server-5.6 mysql-client-core-5.6 mysql-client-5.6
fi
