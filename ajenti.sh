#!/bin/bash
wget http://repo.ajenti.org/debian/key -O- | apt-key add -
echo "deb http://repo.ajenti.org/ng/debian main main ubuntu" >> /etc/apt/sources.list
apt-get update && apt-get install ajenti
service ajenti restart
$ipaddrs = ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
echo "Ajenti Control Panel Running On https://$ipaddrs:8000"
