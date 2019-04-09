#!/system/bin
#Name: setTunaDualNet
#Author: Howard Xue, 2017/6/12
#Function: Auto set static IP for wlan/ethernet, which dynamically assigned from dhcp,and add default gateway
#Param in: default gateway that can access internet, if not enter, this value will be *.*.*.1 of wlan ip 
#Notice: make sure that wlan has not reonnect, we recommend that script is only execute 1 time when network environment changed.
function CheckWlanEthInitialStatus()
{
	if route|grep wlan >/dev/null && route|grep eth >/dev/null;
	then
		if ifconfig wlan0|grep 'inet addr' >/dev/null && ifconfig eth0|grep 'inet addr'>/dev/null;
		then
			echo "WLAN and Ethernet is all connected, Script running..."
		else
			echo "WLAN or Ethernet not have dhcp ip address, now exit..."
			exit
		fi
	else
		echo "WLAN or Ethernet is disconnected, now exit..."
		exit
	fi
}
function CheckWlanStatus()
{
	if route|grep wlan >/dev/null;
	then
		if ifconfig wlan0|grep 'inet addr' >/dev/null;
		then
			:
		else
			echo "WLAN is reconnected, scripts may failed...pls check wlan status"
		fi
	else
		echo "WLAN is reconnected, scripts may failed...pls check wlan status"
	fi
}
	CheckWlanEthInitialStatus
WlanIP=$(ifconfig wlan0|grep 'inet addr' | sed 's/^.*addr://g' | sed 's/Bcast.*$//g')
EtherIP=$(ifconfig eth0|grep 'inet addr' | sed 's/^.*addr://g' | sed 's/Bcast.*$//g')
	echo "Wlan original IP from DHCP is: "$WlanIP
	echo "Ethernet original IP from DHCP is: "$EtherIP
	
	InterIP=${WlanIP%.*}
	InterIPLast=${WlanIP##*.}
	let InterIPLastNew="$InterIPLast+1"
#	WlanInterIP=$InterIP.$InterIPLastNew
	WlanInterIP=$InterIP.255
	WlanDefaultGw=$InterIP.1
	
	InterIPLast="255"
	InterIP=${EtherIP%.*}
	EtherInterIP=$InterIP.$InterIPLast
	echo "eth interm ip is:"$EtherInterIP" wlan interm ip is:"$WlanInterIP
#
		ifconfig wlan0 $WlanInterIP netmask 255.255.255.0 up
		ifconfig eth0 $EtherInterIP netmask 255.255.255.0 up
#		sleep 3;
		CheckWlanStatus
	for i in $(seq 1 1)
	do
		ifconfig eth0 $EtherIP netmask 255.255.255.0 up
		ifconfig wlan0 $WlanIP netmask 255.255.255.0 up
#		ifconfig wlan0 $WlanInterIP netmask 255.255.255.0 up
#		echo "WlanIP is :"$WlanIP
		echo "wait "$i" s..."
		CheckWlanStatus
		sleep 1;
	done
	ifconfig wlan0 up
	ifconfig eth0 up
	
WlanIP=$(ifconfig wlan0|grep 'inet addr' | sed 's/^.*addr://g' | sed 's/Bcast.*$//g')
	echo "Now Wlan Static IP is: " $WlanIP
EtherIP=$(ifconfig eth0|grep 'inet addr' | sed 's/^.*addr://g' | sed 's/Bcast.*$//g')
	echo "Now Ethernet Static IP is: " $EtherIP
	
DefaultGWStatus=$(route | grep default)
	if [$DefaultGWStatus == ""];
	then
		if [ ! -n "$1" ]; then
			echo "Param1 Not Enter, default gw use *.*.*.1 of wlan ip"
			route add default gw $WlanDefaultGw
			echo "Add Default Gateway:" $WlanDefaultGw
		else
			route add default gw $1
			echo "Add Default Gateway:" $1
		fi
	else 
		echo "Default Gateway Existence, pls check it"
	fi

#	pingtime=$(ping -W 1 -c $1 | grep 'ttl')
	if [ ! -n "$1" ]; 
	then
		if ping -c 2 -W 2 $WlanDefaultGw >/dev/null;
		then
			echo "Ping default gw from Para1 "$WlanDefaultGw" Sucess!"
		else
			echo "Ping default gw from Para1"$WlanDefaultGw" failed, now reconfig ip, pls check later..."
			ifconfig eth0 $EtherIP netmask 255.255.255.0 up
#			ifconfig wlan0 $WlanIP netmask 255.255.255.0 up
		fi
	else
		if ping -c 2 -W 2 $1 >/dev/null;
		then
			echo "Ping default gw "$1" Sucess!"
		else
			echo "Ping default gw "$1" failed, now reconfig ip, pls check later..."
			ifconfig eth0 $EtherIP netmask 255.255.255.0 up
#			ifconfig wlan0 $WlanIP netmask 255.255.255.0 up
		fi
		
	fi
	CheckWlanStatus
	if ping -c 2 -W 2 8.8.8.8 >/dev/null;
	then
		echo "Ping Internet 8.8.8.8 Sucess!"
	else
		echo "Ping Internet failed, now reconfig ip, pls also check Wlan..."
		ifconfig eth0 $EtherIP netmask 255.255.255.0 up
#		ifconfig wlan0 $WlanIP netmask 255.255.255.0 up
	fi

