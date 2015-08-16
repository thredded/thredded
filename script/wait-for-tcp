#!/usr/bin/env bash
if [ -z "$2" ]; then cat <<'HELP'; exit; fi
Usage: script/wait-for-tcp ADDRESS PORT
Wait for TCP connection at ADDRESS:PORT, retrying every 3 seconds, maximum 20 times.
HELP

wait_for_tcp() {
  local addr="$1"
  local port="$2"
  local status="down"
  local counter=0
  local wait_time=3
  local max_retries=20
  while [ "$status" = 'down' -a ${counter} -lt ${max_retries} ]; do
    status="$( (echo > "/dev/tcp/${addr}/${port}") >/dev/null 2>&1 && echo 'up' || echo 'down' )"
    if [ "$status" = 'up' ]; then
      echo "Connection to ${addr}:${port} up"
    else
      echo "Waiting ${wait_time}s for connection to ${addr}:${port}..."
      sleep "$wait_time"
      let counter++
    fi
  done
  if [ ${status} = 'down' ]; then
    echo "Could not connect to ${addr}:${port} after ${max_retries} retries"
    exit 1
  fi
}

wait_for_tcp "$1" "$2"
