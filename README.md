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
