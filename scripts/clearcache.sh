#!/usr/bin/env bash

. ~/.files/common.sh
_super_check

echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'
