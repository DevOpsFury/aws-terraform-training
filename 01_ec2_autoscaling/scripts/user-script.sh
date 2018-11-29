#!/bin/bash

set -u
set -e
set -x

apt-get update
apt-get upgrade -y
apt-get install -y unzip zip

# Install CloudWatchMonitoringScripts (perl!)
sudo mkdir -p /opt/cloudwatch
cd /opt/cloudwatch && sudo wget https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
sudo unzip CloudWatchMonitoringScripts-1.2.1.zip
sudo rm -f CloudWatchMonitoringScripts-1.2.1.zip

# Dependencies
sudo apt-get install -y libwww-perl libdatetime-perl

# Set up cron
echo "*/5 * * * * root /opt/cloudwatch/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --from-cron" | sudo tee /etc/cron.d/cloudwatch-mem-disk
echo "*/5 * * * * root /opt/cloudwatch/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --auto-scaling=only --from-cron" | sudo tee /etc/cron.d/cloudwatch-autoscaling

