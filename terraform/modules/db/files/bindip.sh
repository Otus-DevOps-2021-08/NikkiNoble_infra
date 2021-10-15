#!/bin/bash
sudo sed -i -E 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
sudo systemctl restart mongod
