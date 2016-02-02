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
	CURRENT_KERNEL=$(grub-editenv /mnt/grubenv list | grep boot_entry | awk -F "=" '{print $2}')
	echo **Current kernel is $CURRENT_KERNEL > /dev/kmsg

	grub-editenv /mnt/grubenv set prev_kernel=$CURRENT_KERNEL
	if [ "$CURRENT_KERNEL" = "1" ]; then
        	grub-editenv /mnt/grubenv set boot_entry=0
	else
        	grub-editenv /mnt/grubenv set boot_entry=1
	fi
	logger "SABAI:> Booting previous OS...."
	_return 0 "SABAI:> Booting previous OS ..."
	reboot
else
	_return 0 "System Restore is not available."
fi
