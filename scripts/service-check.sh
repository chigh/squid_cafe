#!/usr/bin/env bash
RES_COL=17
. ~/scripts/common.sh

_logger() {
    logger -t MASTODON "$@"
}
status=$(curl -sI https://squid.cafe/about | grep HTTP | awk '{print $2}')

__daemon() {
    if [[ $status -ne 200 ]]; then
        _logger Restarting service: ${status}
        ${HOME}/scripts/mastodon.sh restart
    else
        _logger Service OK
    fi
}

__stdout() {
    printf "Service status: "; $MOVE_TO_COL; printf "[${status}]\n"
    if [[ $status -eq 200 ]]; then
        printf "Service is: "
        $MOVE_TO_COL
        printf "[${green}OK${reset}]\n"
    else 
        printf "Service is: " ; $MOVE_TO_COL ; printf "[${red}DOWN${reset}]\n"
    fi
}

case ${1:-} in
    --status|-s) __stdout ;;
              *) __daemon ;;
esac
