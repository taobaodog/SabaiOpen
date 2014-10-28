#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
act=$1

_return(){
	echo "res={ sabai: $1, msg: '$2' };"
	exit 0
}

_reboot(){
	reboot
	_return 1 "Rebooted"
}

_halt(){
	halt
	_return 1 "Shut Down Complete"
}

_updatepass(){
	pass=$(cat /tmp/hold)
(
         echo $pass
         sleep 1
         echo $pass
)|passwd root
	rm /tmp/hold
	_return 1 "Password Changed"
}


case $act in
	reboot)	_reboot	;;
	halt)	_halt	;;
	updatepass) _updatepass ;;
esac
