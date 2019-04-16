#!/bin/bash

echo -- START CREATING NEW WORDPRESS PROJECT --
echo
CURRENTUSER=$SUDO_USER
DBUSER="root"
DBPASSWORD="root"

# create, if not exists, public_html directory
mkdir -p /home/${CURRENTUSER}/public_html
chown -R ${CURRENTUSER}: /home/${CURRENTUSER}/public_html
chmod -R u+w /home/${CURRENTUSER}/public_html

# get project name
echo "Name of the new Project?"
read -p 'Name: ' WPNAME
echo
echo Perfect. The name is ${WPNAME}.
echo
echo "1# Creating files..."
mkdir /home/${CURRENTUSER}/public_html/${WPNAME}
WPPATH=/home/${CURRENTUSER}/public_html/${WPNAME}
chown -R ${CURRENTUSER}: ${WPPATH}
chmod -R u+w ${WPPATH}
echo
echo "2# Creating virtual host..."
VHOSTS="/etc/httpd/conf/extra/httpd-vhosts.conf"
sudo cat >> ${VHOSTS} <<EOF

<VirtualHost *:80>
    UserDir public_html
    ServerAdmin webmaster@${WPNAME}
    DocumentRoot "/home/${CURRENTUSER}/public_html/${WPNAME}"
    ServerName ${WPNAME}
    ErrorLog "/home/${CURRENTUSER}/public_html/${WPNAME}/error_log"
    CustomLog "/home/${CURRENTUSER}/public_html/${WPNAME}/access_log" common
</VirtualHost>

EOF
HOSTS="/etc/hosts"
sudo cat >> ${HOSTS} <<EOF

127.0.0.1 ${WPNAME}

EOF
echo
echo "3# Installing Wordpress..."
cd /home/${CURRENTUSER}/public_html/${WPNAME}
wget http://wordpress.org/latest.tar.gz
tar xfz latest.tar.gz
rm latest.tar.gz
mv -v /home/${CURRENTUSER}/public_html/${WPNAME}/wordpress/* /home/danny/public_html/${WPNAME} &>/dev/null
rm -rf /home/${CURRENTUSER}/public_html/${WPNAME}/wordpress &>/dev/null
echo
echo "4# Creating database..."
# replace "-" with "_" for database username
MAINDB=${WPNAME//./_}_wpdb

# function to create databes for current user
onlyDB () {
	# If /root/.my.cnf exists then it won't ask for root password
	if [ -f /root/.my.cnf ]; then

    	    mysql -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    	    return 1

	    # If /root/.my.cnf doesn't exist then it'll ask for root password   
	else
    	    echo "Please enter root user MySQL password!"
    	    read ROOTPASSWORD
    	    mysql -uroot -p${ROOTPASSWORD} -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    	    return 1
	fi
}

#function to create database with also new user and password
DBUser () {
	# create random password
	echo
	echo "4.1# Creating random password..."
	PASSWDDB="$(openssl rand -base64 12)"
	DBPASSWORD=${PASSWDDB}
	echo
	echo "Set a username for this account (in case, use _ instead of -):"
	read -p "Username: " DBCUSTOMUSER
	DBUSER=${DBCUSTOMUSER}

	# If /root/.my.cnf exists then it won't ask for root password
	if [ -f /root/.my.cnf ]; then

	    mysql -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
	    mysql -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${DBPASSWORD}';"
	    mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${DBUSER}'@'localhost';"
	    mysql -e "FLUSH PRIVILEGES;"
	    return 1

	# If /root/.my.cnf doesn't exist then it'll ask for root password   
	else
	    echo "Please enter root user MySQL password!"
	    read ROOTPASSWORD
	    mysql -uroot -p${ROOTPASSWORD} -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
	    mysql -uroot -p${ROOTPASSWORD} -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${DBPASSWORD}';"
	    mysql -uroot -p${ROOTPASSWORD} -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${DBUSER}'@'localhost';"
	    mysql -uroot -p${ROOTPASSWORD} -e "FLUSH PRIVILEGES;"
	    return 1
	fi
}
echo
echo "You can create a new database with the default user (normally root), or to create a specific user for this database."
echo
echo "Do you want to create a specific user? [y/n]"
while true; do
    read -p "" yn
        case $yn in
            [Yy]* ) DBUser; break;;
            [Nn]* ) onlyDB; break;;
                * ) echo "Please answer yes or no.";;
            esac
done
echo
echo "5# Restarting Apache..."
systemctl restart httpd
echo
echo "6# Process finished!"
touch ${WPPATH}/access_data.txt
cat >> ${WPPATH}/access_data.txt <<EOF
Address: http://${WPNAME}
Database name: ${MAINDB}
Database user: ${DBUSER}
Database password: ${DBPASSWORD}
Database host: localhost
EOF
echo
echo Address: http://${WPNAME}
echo Database name: ${MAINDB}
echo Database user: ${DBUSER}
echo Database password: ${DBPASSWORD}
echo Database host: localhost
echo
echo "This access data are saved in the access_data.txt inside the project folder."
echo "You can now close the terminal."
