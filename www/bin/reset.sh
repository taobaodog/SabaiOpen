#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology
UCI_PATH="-c /configs"

_return(){
        echo "res={ sabai: $1, msg: '$2' };"
        exit 0;
}

CURRENT_KERNEL=$(grub-editenv /mnt/grubenv list | grep boot_entry | awk -F "=" '{print $2}')
revert_enabled="$(uci get sabai.general.revert)"

if [ -e "/configs/system_$CURRENT_KERNEL" ]; then
	# Copy current custom config
        [ -e /configs/custom_$CURRENT_KERNEL ] ||  mkdir /configs/custom_$CURRENT_KERNEL
        cp -r /etc/config /configs/custom_$CURRENT_KERNEL
        cp -r /etc/sabai/openvpn /configs/custom_$CURRENT_KERNEL/
        cp /configs/sabai /configs/custom_$CURRENT_KERNEL/config
	# Restore system config
	rm -r /etc/config /etc/sabai/openvpn
	cp -fR /configs/system_$CURRENT_KERNEL/config /etc/
	cp -fR /configs/system_$CURRENT_KERNEL/openvpn /etc/sabai/
	mv /etc/config/sabai /configs/
	uci $UCI_PATH  set sabai.general.revert=$revert_enabled
	uci $UCI_PATH commit
	ln -s /configs/sabai /etc/config/sabai
	logger "SABAI:> Factory reset in process. Rebooting ..."
	echo "SABAI:> Sucessfully booted after factory reset." > /www/resUpgrade.txt
	reboot
        _return 0 "SABAI:> Factory reset in process. Rebooting ..."
else
	_return 0 "Factory Reset is NOT available."
fi
