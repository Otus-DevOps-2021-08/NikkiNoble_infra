#!/bin/bash
apt-get update
apt-get install git -y
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
mv /tmp/puma.service /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl enable puma.service
systemctl start puma.service
