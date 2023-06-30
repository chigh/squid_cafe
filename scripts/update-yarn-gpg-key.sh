#!/usr/bin/env bash

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
# /usr/bin/apt-key adv --refresh-keys --keyserver hkp://keyserver.ubuntu.com:80
# /usr/bin/apt-key adv --refresh-keys --keyserver hkps://keyserver.ubuntu.com:443
