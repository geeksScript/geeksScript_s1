#************************************** 
# It accomplishes the following task:
#------------------------------------
# 1. Your script will check if Nginx, Mysql & PHP are installed. If not present, missing packages will be installed.
# 2. Then script will then ask user for domain name. (Suppose user enters example.com)
# 3. Create a /etc/hosts entry for example.com pointing to localhost IP.	
# 4. Create nginx config file for example.com
# 5. Download WordPress latest version from http://wordpress.org/latest.zip and unzip it locally in example.com document root.
# 6. Create a new mysql database for new WordPress. (database name “example.com_db” )
# 7. Create wp-config.php with proper DB configuration. (You can use wp-config-sample.php as your template)
# 8. You may need to fix file permissions, cleanup temporary files, restart or reload nginx config.
# 9. Tell user to open example.com in browser (if all goes well)
#------------------------------------
# Each Block will state about the task it is going to perform and assumptions made, if any.
# Known Possible/Conflicting Errors are redirected to /dev/null.
# Created and Tested on Ubuntu 11.04. 
# Script only for Ubuntu Systems.
# Written By: geeksScript | Sanchit-(http://geeksScript.com), Dated: 03-04-2013.
#************************************** 

#!/bin/sh

add_repo()
# This block adds repository Universe to /etc/apt/sources.list and updates repository
{
echo "Updating Universe Repository";
sudo sh -c "echo deb http://archive.ubuntu.com/ubuntu natty universe >> /etc/apt/sources.list;"
sudo sh -c "echo deb-src http://archive.ubuntu.com/ubuntu natty universe >> /etc/apt/sources.list;"
sudo sh -c "echo deb http://archive.ubuntu.com/ubuntu natty-updates universe >> /etc/apt/sources.list;"
sudo sh -c "echo deb-src http://archive.ubuntu.com/ubuntu natty-updates universe >> /etc/apt/sources.list;"
sudo apt-get update 2> /dev/null;
}


package_check()
# This block checks whether Nginx, Mysql, PHP(with php-mysql) are installed or not. If not, it will install the missing package by apt-get.
# After completing the task, it calls domain_name_task().
{
	add_repo	
	for package in nginx mysql php5-fpm php5-mysql	
	do	
	echo "Checking '$package' installation..Please wait"
	sleep 1
	hash $package 2> /dev/null;
	if [ ! $? = 0 ]; then
		echo "Installing '$package'..Please wait"
		echo
		sleep 1;		
		sudo apt-get update 1> /dev/null;
		if [ $package = 'mysql' ]; then
			sudo apt-get -y install mysql-server;
		else
			sudo apt-get -y install $package;
		fi
		echo "Installed"
	else		
		echo "Installed"
		echo
	fi
	done
	domain_name_task
}


domain_name_task()
# This block ask the value of Domain Name from the user and creates a entry in /etc/hosts pointing to localhost.
# After completing the task, it calls the nginx_task().
{
	echo	
	echo -n "Please enter a Domain Name:";
	read domain_name;
	sudo sh -c "echo 127.0.0.1 $domain_name >> /etc/hosts";
	echo
	echo "$domain_name entry created in /etc/hosts"
	echo
	nginx_task
}


nginx_task()
# This block creates a basic nginx conf file of the domain name which user has entered.
# Conf file is created and updated in the /etc/nginx/sites-available folder and then is sym-linked in /etc/nginx/sites-enabled.
# It also makes a domain name folder in the DocumentRoot.
# Logs are saved in /var/log/nginx.
# After completing the task, it calls the wordpress_task().
{
	sudo chown $(hostname) /etc/nginx/sites-available /etc/nginx/sites-enabled;
	sudo echo "  server {
    listen    80;
    server_name    $domain_name;
    access_log    /var/log/nginx/$domain_name.access.log;
    error_log    /var/log/nginx/$domain_name.error.log;

    location / {
        root    /var/www/$domain_name;
        index    index.php index.html index.htm;
   
    }

    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME /var/www/$domain_name\$fastcgi_script_name;
    }

}
 " > /etc/nginx/sites-available/${domain_name}.conf
	sudo ln -s /etc/nginx/sites-available/${domain_name}.conf /etc/nginx/sites-enabled/${domain_name}.conf;
	sudo chown root /etc/nginx/sites-available /etc/nginx/sites-enabled;
	sudo mkdir /var/www /var/www/$domain_name; 2> /dev/null;
	echo "$domain_name nginx conf file created and linked"; echo
	wordpress_task
}


wordpress_task()
# This block downloads WordPress latest version from http://wordpress.org/latest.zip . Saves and unzip it locally in DocumentRoot.
# After completing the task, it calls the mysql_task().
{
	echo "Downloading latest version of Wordpress..Have Patience"; echo;
	sudo wget http://wordpress.org/latest.zip -O /var/www/$domain_name/latest.zip 1> /dev/null;
	sudo unzip /var/www/$domain_name/latest.zip -d /var/www/$domain_name/ 1> /dev/null;
	echo
	echo "Saved and Unzipped in /var/www/$domain_name/";
	mysql_task
}


mysql_task()
# This block creates a new mysql database for new WordPress with the name database_name_db.
# It will ask for MySql Username/Password from user. If user enters unvalid credentials, it will ask again for valid credentials.
# Password value will not be echo-ed back on screen.
# As '.' character is not allowed in MySql DB name, it will be replace by '_' character.
# After completing the task, it calls the wp-config_task().
{
	domain_nm=$(echo $domain_name | sed 's/\./_/g')
	echo	
	echo "Creating mysql database $db_name";	
	echo -n "Please enter MySql username:"
	read username;
	echo -n "Please enter MySql password:"
	stty -echo
	read password;
	stty echo
	db_name="${domain_nm}_db";
	mysql -u $username -p$password -Bse "CREATE DATABASE $db_name;"
	if [ ! $? = 0 ]; then
		echo
		echo "Username/Password Incorrect..Please try again"
		echo
		mysql_task
	else
	echo "$db_name created..Ok"
	wpconfig_task	
	fi
}


wpconfig_task()
# This block creates a wp-config.php file from the wp-config-sample.php file in the DocumentRoot/wordpress folder.
# wp-conf.php file is updated will the DB name and user-credentials.
# After completing the task, it calls the end_task().
{
	sudo cp /var/www/$domain_name/wordpress/wp-config-sample.php /var/www/$domain_name/wordpress/wp-config.php
	echo "wp-config file created from template"
	sudo sed -i 's/database_name_here/'$db_name'/g' /var/www/$domain_name/wordpress/wp-config.php
	sudo sed -i 's/username_here/'$username'/g' /var/www/$domain_name/wordpress/wp-config.php
	sudo sed -i 's/password_here/'$password'/g' /var/www/$domain_name/wordpress/wp-config.php
	echo "wp-config.php file updated with MySql details"
	end_task
}


end_task()
# This block restarts the /etc/init.d/nginx and php5-fpm service and performs autoclean.
# After successfully completion it tells user to visit: http://$domain_name/wordpress/index.php"
{
	sudo /etc/init.d/nginx restart 1> /dev/null;
	sudo /etc/init.d/php5-fpm restart 1> /dev/null;
	sudo apt-get autoclean 1> /dev/null;
	echo
	echo "All tasks Completed Successfully :-)"
	echo
	echo "Now Please visit: http://$domain_name/wordpress/index.php"
	echo
	exit 0;
}


# Primary Block.
# This block checks the OS. If not Ubuntu, script exits.
# Also,this blocks checks for the Internet Connectivity. If not connected, it tells user to connect to internet & re-run the script.
# After checking it calls the package_check().

lsb_release -a | grep -i ubuntu > /dev/null
if [ ! $? = 0 ]; then
        echo "Script only meant for Ubuntu Systems, Exiting";exit 2;
else
echo "Checking Internet Connectivity.."
ping -W 1 -c 1 google.com 1> /dev/null;

if [ ! $? = 0 ]; then
	echo "Please connect to internet before running this script!"
	exit 1;
	else 
	echo "Connected"
	echo 
	
fi


package_check
fi

