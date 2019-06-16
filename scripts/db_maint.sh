#!/usr/bin/env bash

. ${HOME}/scripts/common.sh

_vacuum() { su - mastodon -c "vacuumdb -v -f -d mastodon_production -z"; }
_reindex() { su - mastodon -c "reindexdb -v -d mastodon_production"; }

case $1 in 
	-v) _vacuum ;;
	-r) _reindex ;;
	-a) _vacuum && _reindex ;;
esac
