#!/bin/ash

echo "SABAI:> Simulate OS upgrade"

CURRENT_KERNEL=$(grub-editenv /mnt/grubenv list | grep boot_entry | awk -F "=" '{print $2}')

#TODO transfer firmware archive to tmpfs
mkdir /tmp/upgrade
wget -P /tmp/upgrade ftp://192.168.0.76/sabai-bundle.tar
tar -C /tmp/upgrade -xf /tmp/upgrade/sabai-bundle.tar
gunzip /tmp/upgrade/rootfs-sabai-img.gz
mv /tmp/upgrade/rootfs-sabai-img /tmp/upgrade/rootfs-sabai.img
umount /dev/sda5
mount /dev/sda1 /mnt
if [ "$CURRENT_KERNEL" = "1" ]; then
	cp -f /tmp/upgrade/openwrt-x86_64-vmlinuz /mnt/boot/vmlinuz2
	dd if=rootfs-sabai.img of=/dev/sda3
else
	cp -f /tmp/upgrade/openwrt-x86_64-vmlinuz /mnt/boot/vmlinuz1
	dd if=rootfs-sabai.img of=/dev/sda2
fi
umount /dev/sda1
mount /dev/sda5 /mnt
#TODO check signature

grub-editenv /mnt/grubenv set prev_kernel=$CURRENT_KERNEL
if [ "$CURRENT_KERNEL" = "1" ]; then
        grub-editenv /mnt/grubenv set boot_entry=0
else
        grub-editenv /mnt/grubenv set boot_entry=1
fi
grub-editenv /mnt/grubenv set is_upgrade=1
umount /dev/sda5

echo "SABAI:> Booting new OS...."
reboot

