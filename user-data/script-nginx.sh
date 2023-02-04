#!/bin/bash
apt-get -y update
apt-get -y install nginx
echo "<h1>NGINX web server is successfully installed and working from $(hostname -f)</h1>" > /var/www/html/index.nginx-debian.html
systemctl enable nginx