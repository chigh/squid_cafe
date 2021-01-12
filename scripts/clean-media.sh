MASTODON=$(id -u mastodon)
(( ${EUID} == ${MASTODON} )) || {
    >&2 printf "This command must be executed as mastodon.\n"
    exit 1
    }

NUM_DAYS=5
RAILS_ENV=production

cd ~/live
bin/tootctl media remove-orphans
bin/tootctl media remove
bin/tootctl preview_cards remove
