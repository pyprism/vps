#!/bin/bash

#date: 20/10/2013 , sunday , 8.32 am 

#check if script run by Mr.Root :P

if [ "$(id -u)" != "0" ]; then
	echo "Sorry man, you are not Mr.Root !"
	exit 1
fi

nisha (){
 echo '######################################################'
 echo "##              $1                                  ##"
 echo '######################################################'
}
#now system update 
apt-get update
apt-get dist-upgrade -y
nisha "System Uptodate "

#apt progress bar for new ubuntu 14.04 version
echo 'Dpkg::Progress-Fancy "1";' > /etc/apt/apt.conf.d/99progressbar

#basic package installation
apt-get install libffi-dev vnstat youtube-dl finger htop python3-dev inxi axel fail2ban python-dev sendmail git python-software-properties software-properties-common python-pip nethogs unzip nmap -y
nisha "Basic package installation complete"

#ppa add
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list

#mongo , nginx and nodejs installation
apt-get update
apt-get install nodejs nginx mongodb-org -y
nisha "nodejs , nginx , mongodb installation complete "

#php 5.6 ppa
add-apt-repository ppa:ondrej/php5-5.6 -y
apt-get update

#php
apt-get install  php5 php5-pgsql php5-fpm php5-json php5-mcrypt php5-imagick php5-geoip php5-gd php5-dev php5-curl php5-cli php5-mysql -y
nisha "Php Installed :/ "

# php-mcrypt fix
ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
php5enmod mcrypt
service php5-fpm restart

#composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
nisha "composer installation complete"

#proxy shadowsocks
pip install shadowsocks
apt-get install python-m2crypto python-gevent -y
nisha "python proxy installation complete"

#512 swap ! 
dd if=/dev/zero of=/swapfile bs=1024 count=512k
mkswap /swapfile
swapon /swapfile
echo "/swapfile       none    swap    sw      0       0 " >> /etc/fstab
echo 0 > /proc/sys/vm/swappiness
chown root:root /swapfile
chmod 0600 /swapfile
nisha "Swap configuration complete"

#fish shell
apt-add-repository ppa:fish-shell/release-2 -y
apt-get update && apt-get install fish -y
#a=which fish
#chsh -s $a

#extra entropy
apt-get install haveged -y
nisha " Haveged installed"

#create new user
echo ":::::Create New User:::::"
echo "Enter User Name=>"
read username
useradd -m $username
echo "user created"
echo "Enter password for new user:"
passwd $username

#MariaD
#apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db 
#add-apt-repository 'deb http://ams2.mirrors.digitalocean.com/mariadb/repo/5.5/ubuntu trusty main'
#apt-get update
apt-get install mysql-server mysql-client libmysqlclient-dev -y
nisha "MySQL installation complete"

#Mysql Secure
mysql_secure_installation

#Postgresql Latest version
#echo "/etc/apt/sources.list.d/pgdg.list"  || tee "/etc/apt/sources.list.d/pgdg.list"
#wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#apt-get update 
#apt-get install -y postgresql-9.4 libpq-dev postgresql-contrib
apt-get install -y postgresql libpq-dev postgresql-contrib
nisha "PostgreSQL Complete"

#redis ! ? :D
add-apt-repository ppa:chris-lea/redis-server -y
apt-get update
apt-get install redis-server -y
nisha "Redis Complete"

#docker.io
wget -qO- https://get.docker.com/ | sh
nisha "Installed Docker"

# some useful packages 
# https://github.com/lebinh/ngxtop
pip install ngxtop virtualenv pip --upgrade
pip install pgcli
npm install bower slap -g

#meteorjs
curl https://install.meteor.com/ | sh
nisha "Meteorjs Complete"

pip install --upgrade pip
#Oh my fish !
curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish

git clone https://github.com/pyprism/vps.git
git clone https://github.com/oussemos/fail2ban-dashboard.git

nisha "All Done . Check If There Is Any Err. "

