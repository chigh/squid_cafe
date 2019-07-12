#!/usr/bin/env bash
sudo s3fs -o allow_other,use_cache=/tmp/cache squid-cafe /backups
