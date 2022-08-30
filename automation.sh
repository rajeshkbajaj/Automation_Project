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
    
