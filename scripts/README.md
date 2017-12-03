# Scripts

* db\_maint.sh
    * typical vacuum and reindex of database
* mastodon\_backup.sh
    * script to make backups of the instance with the option to encrypt to myself.
* mastodon.sh
    * Script to start/stop/restart/enable/disable the mastodon services
* service-check.sh
    * This instance is small and can run occasionally run out of memory. The quickest way to get it back on track is to quickly restart the services. This script is run by cron and when it receives anything other than an HTTP status code of 200, it will attempt to restart the services.
