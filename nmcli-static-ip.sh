#!/bin/bash

subnet=`ip a | grep "inet " | tail -1 | awk '{print $2}'`
router=`ip route show | head -1 | awk '{print $3}'`
sz=`echo $subnet | awk -F / '{print $2}'`
bytes=`expr $sz / 8`
prefix=`echo $subnet | cut -d. -f1-$bytes`
IP=`hostname -I | awk '{print $1}'`

echo "Subnet: $prefix.0/$sz";
echo "Current IP: $IP";
echo "Gateway: $router";
echo -n "Enter DNS: "
read dns

echo -n "Keep current IP? [y/n] > "
read ans
if [ $ans == "n" ]; then
	echo -n "Enter new IP: "
	read IP
	if [[ ! $IP  =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
		echo "Invalid IP!"
	fi

	if [[ ! $IP =~ ^$prefix ]]; then
		echo "Entered IP not usable for local network"
		exit
	fi
fi

if [[ ! $IP =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
	echo "Invalid IP!"
fi

UUID=`nmcli connection show | tail -1 | awk '{print $4}'`

sudo nmcli connection modify $UUID IPv4.address $IP/$sz
sudo nmcli connection modify $UUID IPv4.gateway $router
sudo nmcli connection modify $UUID IPv4.dns $dns
sudo nmcli connection modify $UUID IPv4.method manual
sudo nmcli connection up $UUID

sudo nmcli connection show $UUID | grep ipv4
echo "Ended";

