#!/bin/bash
    cd openwrt_1505
    rm -r files/www
    rm -r files/etc
    cp -rf ../www-mips/ files/www
    cp -rf ../etc-mips/ files/etc

# old config for 14.07 version cp ../scripts/config.0916 .config enable this only if you 
#building anew cp ../scripts/config_ath.1505 .config to enable rtl go to make 
#kernel_menuconfig
		export SABAI_KEYS=/home/SabaiOpen/etc/sabai/keys/ 
		export DEVICE_TYPE=ROUTER 
		export BUILD_TYPE=DEBUG 
		make V=99
#copy Router img to separate dir
dir_now=$(date +"%m-%d-%y_%H-%M") 
mkdir -p ../images/$dir_now
cp -rf ./bin/ar71xx/openwrt-ar71xx-generic-tl-wdr3600-v1-squashfs-sysupgrade.bin ../images/$dir_now/img.bin
cp -rf ./bin/ar71xx/openwrt-ar71xx-generic-tl-wdr3600-v1-squashfs-sysupgrade.bin ../images/latest/img.bin
