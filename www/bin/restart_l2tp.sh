#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
sudo sh /var/www/bin/l2tp.sh stop
sleep 2
sudo /bin/bash /var/www/bin/l2tp.sh start `cat /var/www/usr/l2tp`
