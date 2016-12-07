#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology
UCI_PATH=""

action=$1
vartwo=$2
varthree=$3
varfour=$4

_setup(){
	# Bring in the variables with default of port=1194 and proto=udp
	dhsize=$vartwo
	echo $dhsize
	if [ ! -z $varthree ]; then
		port=$varthree
	else
		port="1194"
	fi
	echo $port
	proto="udp"
	echo $proto

	# Get the external IP
	extip=$(php-fcgi /www/php/get_remote_ip.php | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")
	echo $extip
	
	# Apply the diffie hellman key size
	sed -i "s/KEY_SIZE=[0-9][0-9][0-9][0-9]/KEY_SIZE=$dhsize/g" /etc/easy-rsa/vars

	# Clear any existing OpenVPN configuration
	source /etc/easy-rsa/vars; clean-all
	test=$(ps | grep -v grep | grep -ic sabaivpn)
	if [ $test -eq 1 ]; then
        /etc/init.d/openvpn disable
        /etc/init.d/openvpn stop
	fi

	# Create new OpenVPN server setup based on variables recieved
	build-ca --batch
	build-dh 
	cd /etc/easy-rsa; . ./vars; build-key-server --batch sabai-server
	cp /etc/easy-rsa/keys/ca.crt /etc/easy-rsa/keys/sabai-server.* /etc/easy-rsa/keys/dh*.* /etc/openvpn
	mkdir -p /etc/sabai/openvpn/clients
	touch /etc/sabai/openvpn/clients/dummy
	rm -r /etc/sabai/openvpn/clients/*

	#setup VPN interface
	uci set network.vpn0=interface
	uci set network.vpn0.ifname=tun0 #If you wish to use a server-bridge config, replace the tun0 with tap0
	uci set network.vpn0.proto=none
	uci set network.vpn0.auto=1
	uci commit network
	/etc/init.d/network reload
	sleep 3

	# Setup Firewall rule if it hasn't yet been setup
	test=$(cat /etc/config/firewall | grep -ic OpenVPN)
	if [ $test -eq 0 ]; then
	uci add firewall rule
	uci set firewall.@rule[-1].name=Allow-OpenVPN-Inbound
	uci set firewall.@rule[-1].target=ACCEPT
	uci set firewall.@rule[-1].src=*
	uci set firewall.@rule[-1].proto="$proto"
	uci set firewall.@rule[-1].dest_port="$port"
	# Allow VPN Routing
	uci add firewall zone
	uci set firewall.@zone[-1].name=vpn
	uci set firewall.@zone[-1].input=ACCEPT
	uci set firewall.@zone[-1].forward=REJECT
	uci set firewall.@zone[-1].output=ACCEPT
	uci set firewall.@zone[-1].network=vpn0
	uci add firewall forwarding
	uci set firewall.@forwarding[-1].src='vpn'
	uci set firewall.@forwarding[-1].dest='wan'
	uci commit firewall
	/etc/init.d/firewall restart
	sleep 3
	fi

	# Setup the OpenVPN configuration file
	echo > /etc/config/openvpn # clear the openvpn uci config
	uci set openvpn.sabaivpn=openvpn
	uci set openvpn.sabaivpn.enabled=1
	uci set openvpn.sabaivpn.verb=3
	uci set openvpn.sabaivpn.proto=$proto
	uci set openvpn.sabaivpn.port=$port
	uci set openvpn.sabaivpn.dev=tun
        uci set openvpn.sabaivpn.crl_verify='/etc/easy-rsa/keys/crl.pem'
	uci set openvpn.sabaivpn.server='10.8.199.0 255.255.255.0'
	uci set openvpn.sabaivpn.push='redirect-gateway def1'
	uci set openvpn.sabaivpn.keepalive='10 120'
	uci set openvpn.sabaivpn.ca=/etc/openvpn/ca.crt
	uci set openvpn.sabaivpn.cert=/etc/openvpn/sabai-server.crt
	uci set openvpn.sabaivpn.key=/etc/openvpn/sabai-server.key
	uci set openvpn.sabaivpn.dh=/etc/openvpn/dh$dhsize.pem
	uci commit openvpn
	/etc/init.d/openvpn enable
	/etc/init.d/openvpn start

	# Prepare return messages and return
	test=$(ps | grep -v grep | grep -ic sabaivpn)
	if [ $test -eq 1 ]; then
		success="true"
		message="OpenVPN server is running with $dhsize encryption at $extip : $port with protocol $proto"
		data="none"
	else
		success="false"
		message="OpenVPN server could not be configured properly."
		data="none"
	fi
	_return
}

_client(){
	clientname=$vartwo
	port=$(uci get openvpn.sabaivpn.port)
	proto=$(uci get openvpn.sabaivpn.proto)
	dnsip=$(uci get network.wan.dns|awk '{print $1}')
	if [ $dnsip == "" ]; then
		dnsip='8.8.8.8'
	fi
	# Get the external IP
	extip=$(php-fcgi /www/php/get_remote_ip.php | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")
	echo $extip
	if [ ! -f "/etc/easy-rsa/keys/ca.crt" ]; then 
		success="false"
		message="OpenVPN server must be setup first."
		data="none" 
	else
	build-key --batch $clientname
	cat /etc/sabai/openvpn/clientheader > /etc/sabai/openvpn/clients/$clientname.ovpn
	sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' /etc/easy-rsa/keys/ca.crt >> /etc/sabai/openvpn/clients/$clientname.ovpn
	echo -e "</ca>\n<key>" >> /etc/sabai/openvpn/clients/$clientname.ovpn
	sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' /etc/easy-rsa/keys/$clientname.key >> /etc/sabai/openvpn/clients/$clientname.ovpn
	echo -e "</key>\n<cert>" >> /etc/sabai/openvpn/clients/$clientname.ovpn
	sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' /etc/easy-rsa/keys/$clientname.crt >> /etc/sabai/openvpn/clients/$clientname.ovpn
	echo -e "</cert>" >> /etc/sabai/openvpn/clients/$clientname.ovpn
	sed -i "s/EXTIP/$extip/g" /etc/sabai/openvpn/clients/$clientname.ovpn
 	sed -i "s/PORT/$port/g" /etc/sabai/openvpn/clients/$clientname.ovpn
	sed -i "s/PROTO/$proto/g" /etc/sabai/openvpn/clients/$clientname.ovpn
	sed -i "s/DNSIP/$dnsip/g" /etc/sabai/openvpn/clients/$clientname.ovpn
	fi
	logger "OpenVPN Client $clientname setup."
	success="true"
	message="OpenVPN client $clientname has been setup"
	data="/etc/sabai/openvpn/clients/$clientname.ovpn"
	_return
}

_clear(){
	source /etc/easy-rsa/vars; clean-all
	directory="/etc/sabai/openvpn/clients"
	if [ -d "$directory" ]; then
		rm -r /etc/sabai/openvpn/clients 
	fi
	cd /etc/sabai/openvpn
	logger "OpenVPN Server settings cleared."
	success="true"
	message="OpenVPN server and clients have been cleared"
	data="reload"
	_return
}

_start(){
	test=$(ps | grep -v grep | grep -ic sabaivpn)
	if [ $test -eq 1 ]; then
		logger "Attempted to start OpenVPN server when already running"
		success="false"
		message="OpenVPN server already running"
		data="none"
		_return
	fi

	if [ ! -f "/etc/easy-rsa/keys/ca.crt" ]; then 
		success="false"
		message="OpenVPN server not yet setup"
		data="none"
	else 
		/etc/init.d/openvpn start
		/etc/init.d/openvpn enable
		sleep 5
	fi
	
	test=$(ps | grep -v grep | grep -ic sabaivpn)
	if [ $test -eq 0 ]; then
		success="false"
		message="OpenVPN server did not start"
		data="none"
	else
		success="true"
		message="OpenVPN server started"
		data="none"
	fi
	_return
}

_stop(){
	test=$(ps | grep -v grep | grep -ic sabaivpn)
	if [ $test -eq 0 ]; then
		logger "Tried to stop OpenVPN server when already stopped"
		success="false"
		message="OpenVPN server was already stopped"
		data="none"
		_return
	fi

	if [ ! -f "/etc/easy-rsa/keys/ca.crt" ]; then 
		success="false"
		message="OpenVPN server not yet setup"
		data="none"
	else 
		/etc/init.d/openvpn stop
		/etc/init.d/openvpn disable
		sleep 5
	fi
	
	test=$(ps | grep -v grep | grep -ic sabaivpn)
	if [ $test -eq 0 ]; then
		success="true"
		message="OpenVPN server stopped"
		data="none"
	else
		success="false"
		message="OpenVPN server did not stop"
		data="none"
	fi
	_return
}

_client_off(){
	clientname=$vartwo
	test=$(cat /etc/easy-rsa/keys/index.txt | grep william | awk '{print $1}')
	if [ test = 'R' ]; then
		success="false"
		message="$clientname was already disabled"
		data="none"
	fi
	if [ ! -f "/etc/easy-rsa/keys/$clientname.crt" ]; then 
		cd /etc/easy-rsa
		source ./vars
		revoke-full $clientname
		success="true"
		message="$clientname is disabled"
		data="none"
	else 
		success="false"
		message="$clientname does not exist"
		data="none"
	fi
	_return
}

_check(){
cat /etc/easy-rsa/keys/index.txt | grep fred | awk '{print $1}'
	test=$(ps | grep -v grep | grep -ic sabaivpn)
	if [ $test -eq 1 ]; then
		success="true"
		message="OpenVPN server is running"
		data="none"
	else
		success="false"
		message="OpenVPN server is not running"
		data="none"
	fi
	_return
}

_return(){
	echo "res={ sabai: $success, msg: $message , data: $data };";
	exit 0;
}

case $action in
	setup)  _setup  ;;
	clear)  _clear  ;;
	client)	_client	;;
	client_off_)	_client_off ;;
	start)	_start	;;
	stop)	_stop	;;
	check)	_check	;;
esac
