#!/usr/bin/env bash

SYSTEMD=/etc/systemd/system
LOGFILE=/dev/null

_logger() {
	logger -t MASTODON "$@" 
}

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

_disable() {
	cd $SYSTEMD
	_logger "Disabling mastodon..."
	systemctl disable mastodon-* &> $LOGFILE
	if [[ $? -eq 0 ]]
	then
		_logger "Mastodon disabled."
	else 
		_logger "Mastodon failed to disable."
	fi
}

_enable() { 
	cd $SYSTEMD
	_logger "Enabling mastodon..."
	systemctl enable mastodon-* &> $LOGFILE
	if [[ $? -eq 0 ]]
	then
		_logger "Mastodon enabled."
	else
		_logger "Mastodon failed to enable."
	fi
}

case "$1" in
	start) _start ;;
	stop) _stop ;;
	restart) _stop && _start ;; 
	enable) _enable ;;
	disable) _disable ;;
    backup) shift ; ${HOME}/scripts/mastodon_backup.sh "${@}" ;;
esac
