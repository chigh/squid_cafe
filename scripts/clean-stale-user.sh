cd ~/live
stale_users="/root/stale_users.txt"

for user in $(cat ${stale_users})
do
    username=$(echo ${user} | awk -F'@' '{print $1}')
      domain=$(echo ${user} | awk -F'@' '{print $2}')

set -x
    RAILS_ENV=production bundle exec rails r "
begin
    a = Account.find_by(username: \"${username}\", domain: \"${domain}\")
    a.destroy
rescue => err
end"
set +x

done
