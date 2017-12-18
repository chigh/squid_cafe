#!/usr/bin/env bash
RES_COL=17
. /root/scripts/common.sh
PATH=$PATH:/root/scripts

_logger() {
    logger -t MASTODON "$@"
}
status=$(curl -sI https://squid.cafe/about | grep HTTP | awk '{print $2}')

_start() {
    swapon -a
    cd $SYSTEMD
    _logger "Starting mastodon..."
    systemctl start mastodon-*  &> $LOGFILE
    if [[ $? -eq 0 ]]
    then
        _logger "Mastodon started."
    else
        _logger "Mastodon failed to start."
    fi
}

_stop() {
    cd $SYSTEMD
    _logger "Stopping mastodon..."
    systemctl stop mastodon-* &> $LOGFILE
    if [[ $? -eq 0 ]]
    then
        _logger "Mastodon stopped."
    else
        _logger "Mastodon failed to stop."
    fi
    swapoff -a
}

__daemon() {
    if [[ $status -ne 200 ]]; then
        _logger Restarting service: ${status}
        _stop
        _start
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

_restart() { 
    _stop && _start
}

case "${1:-}" in
    --cron) __daemon ;;
         *) __stdout ;;
esac

#if [[ -z $- ]]
#if [[ -t 0 ]]
#case ${1:-} in
#    --status|-s) __stdout ;;
#              *) __daemon ;;
#esac
