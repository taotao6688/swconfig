#!/bin/sh -x
echo "Writing to /tmp/inputparams"
echo "  db_rootpassword:" >> /tmp/inputparams
echo $db_rootpassword >> /tmp/inputparams
echo "  db_name:" >> /tmp/inputparams
echo $db_name >> /tmp/inputparams
echo "  db_user:" >> /tmp/inputparams
echo $db_user >> /tmp/inputparams
echo "  db_password:" >> /tmp/inputparams
echo $db_password >> /tmp/inputparams
echo "  db_ipaddr:" >> /tmp/inputparams
echo $db_ipaddr >> /tmp/inputparams
sudo yum -y install mariadb mariadb-server
sudo touch /var/log/mariadb/mariadb.log
sudo chown mysql.mysql /var/log/mariadb/mariadb.log
sudo systemctl start mariadb.service

# Setup MySQL root password and create a user
sudo mysqladmin -u root password $db_rootpassword
sudo cat << EOF | mysql -u root --password=$db_rootpassword
CREATE DATABASE $db_name;
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%'
IDENTIFIED BY '$db_password';
FLUSH PRIVILEGES;
EXIT
EOF
