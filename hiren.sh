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
#add-apt-repository ppa:nilarimogard/webupd8 -y
#apt update

#basic package installation
apt-get install btop curl software-properties-common duf zsh ntp libffi-dev ncdu vnstat libpango1.0-0 build-essential finger htop python3-dev inxi axel fail2ban sendmail git nethogs unzip nmap imagemagick webp -y
nisha "Basic package installation complete"

# puppeter
apt install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

# nodejs pre install
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list


# nginx and nodejs install
add-apt-repository ppa:nginx/stable
apt  update
apt  install nodejs nginx -y
nisha "nodejs , nginx installation complete "


#php
#apt install -y php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath
#nisha "Php Installed :/ "

# php-mcrypt fix
#ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
#php5enmod mcrypt
#service php5-fpm restart

#composer
#curl -sS https://getcomposer.org/installer | php
#mv composer.phar /usr/local/bin/composer
#nisha "composer installation complete"

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
mkhomedir_helper $username
echo "user created"
echo "Enter password for new user:"
passwd $username
usermod -a -G $username www-data  # fix for nginx 403 permission error
usermod -a -G sudo $username

#MariaD
#apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db 
#add-apt-repository 'deb http://ams2.mirrors.digitalocean.com/mariadb/repo/5.5/ubuntu trusty main'
#apt-get update
apt  install mysql-server mysql-client libmysqlclient-dev -y
nisha "MySQL installation complete"

#Mysql Secure
mysql_secure_installation

#Postgresql Latest version
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt update 
apt install -y postgresql-16 libpq-dev postgresql-contrib
nisha "PostgreSQL Complete"

#redis ! ? :D
curl https://packages.redis.io/gpg | sudo apt-key add -
echo "deb https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
apt update
apt install redis -y
nisha "Redis Complete"

#docker.io
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
usermod -aG docker $USER
nisha "Installed Docker"

# for  nginx

openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
nisha "dhparam generation completed"

# some useful packages 
# https://github.com/lebinh/ngxtop
pip install ngxtop virtualenv pip --upgrade
pip install pgcli
npm install slap -g
pip install supervisor

# goaccess installation
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | apt-key add -
apt-get update
apt-get install goaccess

# python 3.6
#add-apt-repository ppa:deadsnakes/ppa
#apt update
#apt install python3.6 python3.6-dev

# certbot
apt install python-certbot-nginx certbot

#Oh my zsh !
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#zsh fish like autocomplete
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# CTOP
wget https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.1-linux-amd64 -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

#timezone settings
dpkg-reconfigure tzdata

# Crowdsec
curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash
apt  update
apt install crowdsec
cscli collections install crowdsecurity/whitelist-good-actors
cscli collections install crowdsecurity/endlessh
cscli collections install crowdsecurity/exchange
cscli collections install crowdsecurity/iptables
cscli collections install crowdsecurity/linux
cscli collections install crowdsecurity/mssql
cscli collections install crowdsecurity/nginx
cscli collections install crowdsecurity/sshd
systemctl reload crowdsec


git clone https://github.com/pyprism/vps.git
git clone https://github.com/oussemos/fail2ban-dashboard.git

nisha "All Done . Check If There Is Any Err. "
