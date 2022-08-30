#!/bin/bash

myname="Rajesh"
s3_bucket="upgrad-rajesh"

# Checking and getting updates everytime script runs
sudo apt update -y

# Checking Apache2 server is installed or not 

dpkg -s apache2

if [ $? > 0 ]; then
        echo "Installing apache2 By Rajesh..\n"
        sudo apt install apache2 -y
else
        echo "Apache2 is installed on path -> " `which apache2`
fi

# Check if apache server is Active and running or not

if [ `service apache2 status | grep running | wc -l` == 1 ]
then
        echo "Apache2 is Active and Running"
else
        echo "Apache2 is not Active"
        echo "Starting Apache2"
        sudo service apache2 start

fi

# Check if apache service is Enabled and not

ApacheEnable=$(systemctl is-enabled apache2)
if [ "$ApacheEnable" != "enabled" ]; then
        echo "Apache2 service is Disabled, Enabling Apache2 service";
        sudo systemctl enable apache2
else
        echo "Apache2 service is Enabled"
fi

# Checking AWS Cli is Installed or not 

dpkg -s awscli

if [ $? -ne 0 ]; then
sudo apt install awscli -y
fi

timestamp=$(date '+%d%m%Y-%H%M%S')

echo "Switching to tmp directory to store logs"

cd /var/log/apache2/

tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log

echo "Copy logs to s3 bucket"

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

echo "Checks if inventory.html exists in /var/wwww/html folder"

if [ -e /var/www/html/inventory.html ]
then
 echo "Inventory.html file does exists"
 
else

 touch /var/www/html/inventory.html
 echo "<b>Log Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Date Created &nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp; Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Size</b>" >> /var/www/html/inventory.html
fi

echo "<br>httpd-logs &nbsp;&nbsp;&nbsp;&nbsp; ${timestamp} &nbsp;&nbsp;&nbsp;&nbsp; tar &nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp; `du -h /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}'`"             >> /var/www/html/inventory.html

echo "Checks and Add the script to CRON "

if [ -e /etc/cron.d/automation ]
then
        echo "Cron Job file is already available"
else
        touch /etc/cron.d/automation
        echo "0 0 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
        echo "Cron Job file has been created"
fi
