#!/usr/bin/env bash
# https://docs.joinmastodon.org/admin/tootctl

export RAILS_ENV=production
DAYS=4

# Clear the cache
/home/mastodon/live/bin/tootctl cache clear

# Prune remote accounts that never interacted with a local user
/home/mastodon/live/bin/tootctl accounts prune;

# Remove remote statuses that local users never interacted with older than $DAYS days
/home/mastodon/live/bin/tootctl statuses remove --days ${DAYS};

# Remove media attachments older than $DAYS days
/home/mastodon/live/bin/tootctl media remove --days ${DAYS};

# Remove all headers (including people I follow)
/home/mastodon/live/bin/tootctl media remove --remove-headers --include-follows --days 0;

# Remove link previews older than $DAYS days
/home/mastodon/live/bin/tootctl preview_cards remove --days ${DAYS};

# Remove files not linked to any post
/home/mastodon/live/bin/tootctl media remove-orphans;
