#!/usr/bin/env bash

stale_users="/root/stale_users.txt"

sudo -i -u postgres /bin/bash -l -c "psql -A -d mastodon_production \
    -c \"SELECT username||'@'||domain FROM public.accounts WHERE last_webfingered_at < \
    (CURRENT_TIMESTAMP - interval '3 months')\"" | \
    tail -n +2 | head -n -1 > ${stale_users}
