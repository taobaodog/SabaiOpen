#!/bin/sh

TOPDIR="$1"

# copy config files
mv $TOPDIR/files/etc/sabai/accelerator/network $TOPDIR/files/etc/config/network
mv $TOPDIR/files/etc/sabai/accelerator/firewall $TOPDIR/files/etc/config/firewall
mv $TOPDIR/files/etc/sabai/accelerator/firewall.user $TOPDIR/files/etc/firewall.user
mv $TOPDIR/files/etc/sabai/accelerator/uhttpd $TOPDIR/files/etc/config/uhttpd
mv $TOPDIR/files/etc/sabai/accelerator/dhcp $TOPDIR/files/etc/config/dhcp
mv $TOPDIR/files/etc/sabai/accelerator/dropbear $TOPDIR/files/etc/config/dropbear

# changing config
sed -i "s/option hostname 'SabaiOpen'/option hostname 'vpna'/" $TOPDIR/files/etc/config/system
sed -i "s/option hostname 'SabaiOpen'/option hostname 'vpna'/" $TOPDIR/files/etc/config/sabai
sed -i "s/option hostname 'SabaiOpen'/option hostname 'vpna'/" $TOPDIR/files/etc/config/network
sed -i '5,8d' $TOPDIR/files/etc/rc.local
echo "echo 1 > /proc/sys/net/ipv4/conf/eth0/proxy_arp" >> $TOPDIR/files/etc/rc.local
echo ". /etc/init.d/dropbear enable" >> $TOPDIR/files/etc/rc.local
echo ". /etc/init.d/dropbear start" >> $TOPDIR/files/etc/rc.local
echo -e "logger \"Test date here!\""
echo "date >> /etc/sabai/sys_reset" >> $TOPDIR/files/etc/rc.local


# copy and rm sh
mv $TOPDIR/files/etc/init.d/sabaifs_release $TOPDIR/files/etc/init.d/sabaifs
mv $TOPDIR/files/etc/sabai/accelerator/config_upload_ACC.sh $TOPDIR/files/www/bin/config_upload.sh

# copy and rm php
mv $TOPDIR/files/etc/sabai/accelerator/menu.php $TOPDIR/files/www/php/menu.php
mv $TOPDIR/files/etc/sabai/accelerator/network.wan.php $TOPDIR/files/www/v/network.wan.php
mv $TOPDIR/files/etc/sabai/accelerator/menuHeader.png $TOPDIR/files/www/libs/img
mv $TOPDIR/files/etc/sabai/accelerator/network.radio.php $TOPDIR/files/www/v/
mv $TOPDIR/files/etc/sabai/accelerator/help_ACC.php $TOPDIR/files/www/v/help.php

# Removing ../v/*.php
rm $TOPDIR/files/www/v/network.lan.php
rm $TOPDIR/files/www/v/wireless.radio.php
rm $TOPDIR/files/www/v/vpn.gateways.php
rm $TOPDIR/files/www/v/security.dmz.php
rm $TOPDIR/files/www/v/security.firewall.php
rm $TOPDIR/files/www/v/security.portforwarding.php
rm $TOPDIR/files/www/v/security.upnp.php

# Removing ../php/*.php
rm $TOPDIR/files/www/php/lan.php
rm $TOPDIR/files/www/php/dhcp.php
rm $TOPDIR/files/www/php/dmz.php
rm $TOPDIR/files/www/php/firewall.php
rm $TOPDIR/files/www/php/portforwarding.php
rm $TOPDIR/files/www/php/upnp.php

# Removing ../bin/*.sh
rm $TOPDIR/files/www/bin/lan.sh
rm $TOPDIR/files/www/bin/dhcp.sh
rm $TOPDIR/files/www/bin/dmz.sh
rm $TOPDIR/files/www/bin/firewall.sh
rm $TOPDIR/files/www/bin/pftable.sh
rm $TOPDIR/files/www/bin/portforwarding.sh
rm $TOPDIR/files/www/bin/upnp.sh
