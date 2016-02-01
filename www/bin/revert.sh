#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology

CURRENT_KERNEL=$(grub-editenv /mnt/grubenv list | grep boot_entry | awk -F "=" '{print $2}')
echo **Current kernel is $CURRENT_KERNEL > /dev/kmsg

grub-editenv /mnt/grubenv set prev_kernel=$CURRENT_KERNEL
if [ "$CURRENT_KERNEL" = "1" ]; then
        grub-editenv /mnt/grubenv set boot_entry=0
else
        grub-editenv /mnt/grubenv set boot_entry=1
fi
