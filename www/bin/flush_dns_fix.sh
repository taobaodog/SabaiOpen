#!/bin/ash
for i in $(uci show firewall | grep -e "dest_port='5353'" | cut -d "[" -f2 | cut -d "]" -f1 | sort -r); do
	uci delete firewall.@redirect[$i]
	uci commit firewall
done
/etc/init.d/firewall restart > /dev/null
