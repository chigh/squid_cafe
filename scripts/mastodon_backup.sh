#!/usr/bin/env bash

DATE=$(date +%Y%m%d)
TIME=$(date +%s)
BACKUP_HOME=${HOME}/backups
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
        #&& success || fail
fi

_backup_db() {
#printf "Backing up database..." 
    su - mastodon -c "pg_dump mastodon_production > ${DB_BACKUP}" && \
	    mv /home/mastodon/${DB_BACKUP} ${BACKUP_DIR} 
        #&& success || fail
}

_backup_conf() {
#printf "Backing up configuration..."
    cp /home/mastodon/live/config/settings.yml ${BACKUP_DIR} 
        #&& success || fail
}

_backup_env() {
#printf "Backing up environment..."
    cp /home/mastodon/live/.env.production $BACKUP_DIR #&& success || fail
    cp /home/mastodon/.bash_[af]* $BACKUP_DIR
    cp -pr ${HOME}/scripts $BACKUP_DIR
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
            gpg --batch --yes -es -o $file.gpg -r clair.high@tch3.com $file
            rm -f $file
        fi
    done
}
case ${1:-} in 
   --encrypt|-e) _clean_up; _encrypt ;; 
     *) _backup_db; 
        _backup_conf; 
        _backup_env;
        _create_archive;
        _clean_up;;
esac
