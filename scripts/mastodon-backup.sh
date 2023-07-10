#!/usr/bin/env bash

set -o xtrace

DATE=$(date +%Y%m%d)
TIME=$(date +%s)
BACKUP_HOME=/home/backup/data/db
BACKUP_DIR=$BACKUP_HOME/$DATE
DB_BACKUP=mastodon_production.sql

_clean_up() {
    #printf "Cleaning up..."
	rm -rf $BACKUP_DIR 
        #&& success || fail
}

trap "{ 
    printf '\n'; 
    alert \"caught interrupt: exiting\"; 
    exit_status="2"; 
    _clean_up;
    exit 2; 
}" INT 

if [[ ! -d $BACKUP_DIR ]]
then
	#printf "Creating backup directory..."
	mkdir -p $BACKUP_DIR 
    chown mastodon:mastodon $BACKUP_DIR
        #&& success || fail
fi

_backup_db() {
#printf "Backing up database..." 
    #su - mastodon -c "pg_dump mastodon_production > ${BACKUP_DIR}/${DB_BACKUP}" # && \
    runuser -l mastodon -c "cd ~ && pg_dump -Fc mastodon_production -f ${BACKUP_DIR}/${DB_BACKUP}"
	    #mv /home/mastodon/${DB_BACKUP} ${BACKUP_DIR} 
        #&& success || fail
}

_backup_conf() {
#printf "Backing up configuration..."
    cp /home/mastodon/live/config/settings.yml ${BACKUP_DIR} 
        #&& success || fail
}

_backup_env() {
#printf "Backing up environment..."
    rsync -aic /home/mastodon/live/.env.production $BACKUP_DIR #&& success || fail
    rsync -aic /home/mastodon/.bash_[af]* $BACKUP_DIR
    rsync -aic ${HOME}/scripts $BACKUP_DIR
}

_backup_redis() {
    rsync -aic /var/lib/redis/dump.rdb $BACKUP_DIR
}

_create_archive() {
    chown -Rh root:root ${BACKUP_DIR}
    find $BACKUP_DIR -type f -exec chmod 660 '{}' \;

#printf "Archiving backup..."
    ( cd $BACKUP_DIR ; tar cf mastodon-assets-${DATE}.tar /home/mastodon/live/public/system )
    ( cd $BACKUP_HOME ; tar zcf mastodon-backup-${DATE}.tgz $DATE ) 
}

_final_perms() { 
    find $BACKUP_HOME -type f -exec chown chigh '{}' \; 
}

_encrypt() {
    for file in $(find $BACKUP_HOME -type f -name \*.tgz)
    do
        if [[ ! -e ${file}.gpg ]]; then
            gpg --batch --yes -e -o $file.gpg -r chigh@keybase.io $file
            rm -f $file
        fi
        #if [[ -e ${file}.gpg ]]; then
        #    cp ${file}.gpg /backups && rm ${file}.gpg
        #fi
    done
}

_purge() {
    cd $BACKUP_HOME
    ls -1pr | grep -v '/$' | tail -n +8 | tr '\n' '\0' | xargs -0 rm --
    # (ls -t|head -n 5;ls)|sort|uniq -u|xargs rm
    # (ls -t|head -n 5;ls)|sort|uniq -u|sed -e 's,.*,"&",g'|xargs rm
}
_everything() {
    _backup_db
    _backup_conf
    _backup_env
    _backup_redis
    _create_archive
    _clean_up
    _encrypt
}
case ${1:-} in 
   -d) _backup_db ;;
   --encrypt|-e) _clean_up; _encrypt ; _purge ;; 
    -p) _clean_up; _purge ;;
    -a) _everything ;;
     *) _backup_db; 
        _backup_conf; 
        _backup_env;
        _backup_redis;
        _create_archive;
        _encrypt;
        _clean_up;;
esac
