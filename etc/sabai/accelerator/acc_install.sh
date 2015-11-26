#!/bin/sh

TOPDIR="$1"

# copy config files
mv $TOPDIR/files/etc/sabai/accelerator/network $TOPDIR/files/etc/config/network
mv $TOPDIR/files/etc/sabai/accelerator/firewall $TOPDIR/files/etc/config/firewall
mv $TOPDIR/files/etc/sabai/accelerator/uhttpd $TOPDIR/files/etc/config/uhttpd

# changing config
sed -i "s/option hostname 'SabaiOpen'/option hostname 'VPNA'/" $TOPDIR/files/etc/config/system
sed -i "s/option hostname 'SabaiOpen'/option hostname 'VPNA'/" $TOPDIR/files/etc/config/sabai
sed -i "s/option hostname 'SabaiOpen'/option hostname 'VPNA'/" $TOPDIR/files/etc/config/network
sed -i '5,8d' $TOPDIR/files/etc/rc.local
echo "echo 1 > /proc/sys/net/ipv4/conf/eth0/proxy_arp" >> $TOPDIR/files/etc/rc.local

# copy and rm sh
mv $TOPDIR/files/etc/init.d/sabaifs_release $TOPDIR/files/etc/init.d/sabaifs
mv $TOPDIR/files/etc/sabai/accelerator/ovpn_acc.sh $TOPDIR/files/www/bin/ovpn.sh
mv $TOPDIR/files/etc/sabai/accelerator/pptp_acc.sh $TOPDIR/files/www/bin/pptp.sh

# copy and rm php
mv $TOPDIR/files/etc/sabai/accelerator/menu.php $TOPDIR/files/www/php/menu.php
mv $TOPDIR/files/etc/sabai/accelerator/network.wan.php $TOPDIR/files/www/v/network.wan.php
mv $TOPDIR/files/etc/sabai/accelerator/menuHeader.png $TOPDIR/files/www/libs/img

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
rm $TOPDIR/files/www/php/get_wl_channel.php
rm $TOPDIR/files/www/php/wl.php
rm $TOPDIR/files/www/php/dhcp.php
rm $TOPDIR/files/www/php/dmz.php
rm $TOPDIR/files/www/php/firewall.php
rm $TOPDIR/files/www/php/portforwarding.php
rm $TOPDIR/files/www/php/upnp.php

# Removing ../bin/*.sh
rm $TOPDIR/files/www/bin/lan.sh
rm $TOPDIR/files/www/bin/wl.sh
rm $TOPDIR/files/www/bin/wl_channel.sh
rm $TOPDIR/files/www/bin/dhcp.sh
rm $TOPDIR/files/www/bin/dmz.sh
rm $TOPDIR/files/www/bin/firewall.sh
rm $TOPDIR/files/www/bin/pftable.sh
rm $TOPDIR/files/www/bin/portforwarding.sh
rm $TOPDIR/files/www/bin/upnp.sh
