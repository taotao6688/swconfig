#!/bin/sh -x
echo "  db_ipaddr" >> /tmp/inputparams
echo $db_ipaddr >> /tmp/inputparams
sudo yum -y install httpd wordpress
sudo sed -i "/Deny from All/d" /etc/httpd/conf.d/wordpress.conf
sudo sed -i "s/Require local/Require all granted/" /etc/httpd/conf.d/wordpress.conf
sudo sed -i s/database_name_here/$db_name/ /etc/wordpress/wp-config.php
sudo sed -i s/username_here/$db_user/      /etc/wordpress/wp-config.php
sudo sed -i s/password_here/$db_password/  /etc/wordpress/wp-config.php
sudo sed -i s/localhost/$db_ipaddr/        /etc/wordpress/wp-config.php
sudo sed -i "s/DocumentRoot \"\/var\/www\/html\"/DocumentRoot \"\/usr\/share\/wordpress\"/"      /etc/httpd/conf/httpd.conf

sudo setenforce 0 # Otherwise net traffic with DB is disabled

sudo systemctl start httpd.service
