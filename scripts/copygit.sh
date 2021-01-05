#!/usr/bin/env bash
. ~/scripts/common.sh

set +o errexit 

dest=/home/chigh/src/squid_cafe/scripts

cd ~/scripts

for file in mastodon_backup.sh mastodon.sh service-check.sh update.sh 
do
    cko=$(shasum -a 512 $file | awk '{print $1}')
    ckd=$(shasum -a 512 $dest/$file | awk '{print $1}')
    if [[ "${ckd}" != "${cko}" ]]; then
        cp -v $file $dest
    fi
done
