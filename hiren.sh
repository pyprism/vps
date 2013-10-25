#!/usr/bash

#date: 20/10/2013 , sunday , 8.32 am 

#check if script runned by Mr.Root :P

if [ "$(id -u)" != "0" ]; then
	echo "Sorry man, you are not Mr.Root !"
	exit 1
fi
#now system update 
apt-get update
apt-get dist-upgrade -y
echo "Your system up2date"

#basic package installation
apt-get install vnstat finger htop axel fail2ban sendmail git python-software-properties software-properties-common python-pip nethogs unzip nmap -y
echo "Basic package installation complete"

#ppa add
add-apt-repository ppa:chris-lea/node.js -y
add-apt-repository ppa:nginx/stable -y
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list

apt-get update
apt-get install nodejs nginx mongodb-10gen -y
echo "nodejs , nginx , mongodb installation completed "

#proxy shadowsocks
pip install shadowsocks
apt-get install python-m2crypto python-gevent -y
echo "proxy installed"
