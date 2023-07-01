#!/bin/sh
# Original: https://github.com/Wonderfall/dockerfiles/
#           https://github.com/Wonderfall/dockerfiles/blob/master/mastodon/targaryen/targaryen.sh

### Increase number of characters / toot
#sed -i -e 's/500/800/g' \
    #app/javascript/mastodon/features/compose/components/compose_form.js \
    #app/validators/status_length_validator.rb \
    # obsolete #storybook/stories/character_counter.story.js \
    # obsolete #config/locales/*.yml

### Increase bio length -- obsolete
# cd live
#sed -i -e 's/160/300/g' \
#    app/javascript/packs/public.js \
#    app/models/account.rb \
#    app/views/settings/profiles/show.html.haml

### fields in bio set to 5 instead of 4 app/models/account.rb ~ +95
# validates :fields, length: { maximum: 5 }, if: -> { local? && will_save_change_to_fields? }


### Dragon emoji
#sed -i -e 's/1f602/1f432/g' \
    #app/javascript/mastodon/features/compose/components/emoji_picker_dropdown.js

cd config/locales

### Change "Toots" to "Posts" on profile pages
sed -i -e 's/Toots with replies/Posts with replies/' \
    es.yml \
    eo.yml \
    sv.yml \
    nl.yml \
    pt-BR.yml \
    en.yml \
    ca.yml

sed -i -e 's/Toots/Posts/g' \
    es.yml \
    eo.yml \
    sv.yml \
    nl.yml \
    pt-BR.yml \
    en.yml \
    ca.yml
