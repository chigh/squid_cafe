#!/usr/bin/env bash

SYSTEMD=/etc/systemd/system
LOGFILE=/dev/null

function _logger() {
	logger -t MASTODON "$@" 
}

function _start() { 
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

function _stop() {
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

function _disable() {
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

function _enable() { 
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

function _mastlog() { grep MASTODON /var/log/syslog | less; }

function _db_maint() {
    su - mastodon -c "vacuumdb -v -d mastodon_production -z";
    su - mastodon -c "reindexdb -v -d mastodon_production";
}

function _quick_restart() {
    systemctl restart mastodon-sidekiq
    systemctl reload mastodon-web
    systemctl restart mastodon-streaming
}


if [[ $(basename $0) == "quick-restart.sh" ]]; then
    _quick_restart
    exit $?
fi

case "$1" in
	start)      _start          ;;
	stop)       _stop           ;;
	restart)    _quick_restart  ;;
	enable)     _enable         ;;
	disable)    _disable        ;;
    --log)      _mastlog        ;;
    --db)       _db_maint       ;;
esac
