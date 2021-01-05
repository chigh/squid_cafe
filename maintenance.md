# See: https://docs.joinmastodon.org/admin/tootctl

## Only Occasionally 
```
bin/tootctl accounts cull
~/scripts/clean-media.sh
```

## Semi-regularly

```
stale-users.sh --find
stale-users.sh --clean
```

## Regularly

[admin cleanup tasks](https://docs.joinmastodon.org/admin/setup/) (see also crontab)

```
bin/tootctl media remove
bin/tootctl preview_cards remove
```


