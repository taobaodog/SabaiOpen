#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology
UCI_PATH="-c /configs"

_return(){
	echo "res={ sabai: $1, msg: '$2' };"
	exit 0;
}

revert_enabled=$(uci get $UCI_PATH sabai.general.revert)

if [ "$revert_enabled" = "1" ]; then
	mount -t ext4 /dev/sda5 /mnt
	CURRENT_KERNEL=$(grub-editenv /mnt/grubenv list | grep boot_entry | awk -F "=" '{print $2}')
	logger **Current kernel is $CURRENT_KERNEL

	# Copy current custom config
	[ -e /configs/custom_$CURRENT_KERNEL ] ||  mkdir /configs/custom_$CURRENT_KERNEL
	cp -r /etc/config /configs/custom_$CURRENT_KERNEL
	cp -r /etc/sabai/openvpn /configs/custom_$CURRENT_KERNEL/

	grub-editenv /mnt/grubenv set prev_kernel=$CURRENT_KERNEL
	if [ "$CURRENT_KERNEL" = "1" ]; then
        	grub-editenv /mnt/grubenv set boot_entry=0
	else
        	grub-editenv /mnt/grubenv set boot_entry=1
	fi
	grub-editenv /mnt/grubenv set is_revert=1
	umount /dev/sda5
	logger "SABAI:> Booting previous OS...."
	reboot
	_return 0 "SABAI:> Booting previous OS ..."
else
	_return 0 "System Restore is not available."
fi
