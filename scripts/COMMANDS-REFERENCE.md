## Demote Admin to User

```
RAILS_ENV=production bundle exec rails c
Account.find_local('username').user.update(admin: false)
```
