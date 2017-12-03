#!/usr/bin/env bash

_logger() {
    logger -t MASTODON "$@"
}
status=$(curl -sI https://squid.cafe/about | grep HTTP | awk '{print $2}')

if [[ $status -ne 200 ]]; then
    _logger Restarting service: ${status}
    ${HOME}/scripts/mastodon.sh restart
else
    _logger Service OK
fi
