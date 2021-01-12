# See: https://docs.joinmastodon.org/admin/tootctl

## Only Occasionally 
occasional() {
    cd ~/live ; bin/tootctl accounts cull
    ~/scripts/clean-media.sh
}

## Semi-regularly
semi_regular() {
    ~/scripts/stale-users.sh --find
    ~/scripts/stale-users.sh --clean
}

## Regularly
regularly() {
    # [admin cleanup tasks](https://docs.joinmastodon.org/admin/setup/) (see also crontab)
    cd ~/live; bin/tootctl media remove
    cd ~/live; bin/tootctl preview_cards remove
}

_usage() {
    printf "$(basename $0) OPTION\n"
    printf "\t--ocasionally, -o     run occasionally
\t--semiregular, -s     run more often than occasionally
\t--regularly, -r       run this fairly often\n"
}
case ${1:-} in 
    --occasionally|-o) occasional   ;;
     --semiregular|-s) semi_regular ;;
       --regularly|-r) regularly    ;;
                    *) printf "error: invalid argument\n" ; _usage ;;
esac
