# Scripts
Scripts for maintenance, etc.  

See also maintenance.md

* db\_maint.sh
    * typical vacuum and reindex of database
* clean-media.sh
    * cleans remote media, orphans, and preview cards
* mastodon\_backup.sh
    * script to make backups of the instance and encrypt them
    * only keep 7 days worth
* mastodon.sh
    * Script to start/stop/restart/enable/disable the mastodon services
* service-check.sh
    * This instance is small and can run occasionally run out of memory. The quickest way to get it back on track is to quickly restart the services. This script is run by cron and when it receives anything other than an HTTP status code of 200, it will attempt to restart the services.
* stale-users.sh
    * find stale users, clean them and their data off the system
