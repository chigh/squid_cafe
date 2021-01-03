MASTODON=$(id -u mastodon)
(( ${EUID} == ${MASTODON} )) || {
    >&2 printf "This command must be executed as mastodon.\n"
    exit 1
    }

cd ~/live
bin/tootctl media remove-orphans
