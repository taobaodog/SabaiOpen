#!/bin/ash

number_conf=0
count=0
#clear configList.txt
cat /dev/null > /www/configList

#mounting partition with config files
mount -t ext4 /dev/sda6 /mnt
echo mount sda6 command executed with: $? > /dev/kmsg

#searching for config files on partition
config_list=`ls -p /mnt | grep -v / | sed 's/\/mnt\///'`

#counting number of avaliable config files
for i in  $(echo "$config_list"); do
	number_conf=$((number_conf+1))
done

#try to do JSON
#echo -e "{" >> /www/configList
for i in $config_list; do
	count=$((count+1))
	echo -e "\"conf_$count\": \"$i\"," >> /www/configList
done
#echo -e \"Number\": \"$number_conf\" >> /www/configList
#echo "}" >> /www/configList
strout=`cat /www/configList | tr '\n' ' '| sed 's/.$//' | sed 's/.$//'`
#strout= $str | sed 's/.$//'
echo $strout
umount /dev/sda6

