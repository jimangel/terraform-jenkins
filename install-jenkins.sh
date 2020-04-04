#!/usr/bin/env bash

echo "doing this: https://askubuntu.com/questions/272248/processing-triggers-for-man-db"
sudo apt-get remove -y --purge man-db

# random cleanup?
sudo dmsetup mknodes

sudo apt update -y

echo "install a few prerequisite packages which let apt use packages over HTTPS"
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

echo "add docker key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt install docker-ce

echo "Add the Docker repository to APT sources"
sudo add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

echo "updating repos"
sudo apt update -y

echo "Install Java JDK"
sudo apt install default-jdk-headless -y 

echo "Install Docker engine"
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker

echo "Install Jenkins"
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -y
sudo apt install jenkins -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow proto tcp from any to any port 80,443
echo "y" | sudo ufw enable

# install nginx and certbot
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt install certbot python-certbot-nginx unzip -y

sudo mv -f /tmp/jenkins-nginx-conf /etc/nginx/sites-available/default
sudo sed -i "s/ssl_protocols TLSv1 TLSv1.1 TLSv1.2/ssl_protocols TLSv1.2 TLSv1.3/g" /etc/nginx/nginx.conf
sudo service nginx restart

# turn on swap
sudo fallocate -l 1G /swapfile
ls -lh /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# install plugins
sudo bash /tmp/install-plugins.sh configuration-as-code-support pipeline-maven blueocean workflow-aggregator

# skip wizard
sudo sed -i 's/NEW/RUNNING/g' /var/lib/jenkins/config.xml

# moving config into a valid directory
sudo mv -f /tmp/jenkins.yaml /var/lib/jenkins/jenkins.yaml

sudo service jenkins restart