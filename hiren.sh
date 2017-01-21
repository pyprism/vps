#!/bin/bash

#date: 20/10/2013 , sunday , 8.32 am 

#check if script run by Mr.Root :P
set -eu

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
apt  update
apt   dist-upgrade -y
nisha "System Uptodate "

#apt progress bar for new ubuntu 14.04 version
#echo 'Dpkg::Progress-Fancy "1";' > /etc/apt/apt.conf.d/99progressbar

# webupd8 ppa for youtube-dl
add-apt-repository ppa:nilarimogard/webupd8 -y
apt update

#basic package installation
apt-get install zsh ntp libffi-dev vnstat youtube-dl letsencrypt finger htop python3-dev inxi axel fail2ban python-dev sendmail git python-software-properties software-properties-common python-pip nethogs unzip nmap -y
nisha "Basic package installation complete"

#ppa add
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

#nginx and nodejs installation
apt  update
apt  install nodejs nginx -y
nisha "nodejs , nginx installation complete "


#php
apt-get install  php7.0 php7.0-mbstring php7.0-pgsql php7.0-fpm php7.0-json php7.0-mcrypt php-geoip php7.0-gd php7.0-dev php7.0-curl php7.0-cli php7.0-mysql php7.0-bcmath php-bcmath -y
nisha "Php Installed :/ "

# php-mcrypt fix
#ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
#php5enmod mcrypt
#service php5-fpm restart

#composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
nisha "composer installation complete"

#proxy shadowsocks
#pip install shadowsocks
#apt-get install python-m2crypto python-gevent -y
#nisha "python proxy installation complete"

#2G swap ! 
dd if=/dev/zero of=/swapfile bs=4024 count=512k
mkswap /swapfile
swapon /swapfile
echo "/swapfile       none    swap    sw      0       0 " >> /etc/fstab
echo 0 > /proc/sys/vm/swappiness
chown root:root /swapfile
chmod 0600 /swapfile
nisha "Swap configuration complete"

#fish shell
#apt-add-repository ppa:fish-shell/release-2 -y
#apt-get update && apt-get install fish -y
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
apt  install mysql-server mysql-client libmysqlclient-dev -y
nisha "MySQL installation complete"

#Mysql Secure
mysql_secure_installation

#Postgresql Latest version
#echo "/etc/apt/sources.list.d/pgdg.list"  || tee "/etc/apt/sources.list.d/pgdg.list"
#wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#apt-get update 
#apt-get install -y postgresql-9.4 libpq-dev postgresql-contrib
apt  install -y postgresql libpq-dev postgresql-contrib
nisha "PostgreSQL Complete"

#redis ! ? :D
#add-apt-repository ppa:chris-lea/redis-server -y
apt install redis-server -y
nisha "Redis Complete"

#docker.io
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > "/etc/apt/sources.list.d/docker.list"
apt update
apt install docker-engine -y
nisha "Installed Docker"

# for  nginx

openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
nisha "dhparam generation completed"

# some useful packages 
# https://github.com/lebinh/ngxtop
pip install ngxtop virtualenv pip --upgrade
pip install pgcli
npm install bower slap -g


pip install --upgrade pip
pip install supervisor

# goaccess installation
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | apt-key add -
apt-get update
apt-get install goaccess

#Oh my zsh !
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/pyprism/vps.git
git clone https://github.com/oussemos/fail2ban-dashboard.git

nisha "All Done . Check If There Is Any Err. "

