#!/bin/bash

function addClient() {
	# Load params
	source /etc/wireguard/params

	if [[ $SERVER_PUB_IP =~ .*:.* ]]; then
		echo "A public IPv6 address detected on server - doublecheck at the end to ensure you configure an IPv4 fallback"
		ENDPOINT="[$SERVER_PUB_IP]:$SERVER_PORT"
	else
		# echo "IPv4 Detected"
		ENDPOINT="$SERVER_PUB_IP:$SERVER_PORT"
	fi

	WG_CLIENT_COUNT=1
	if [ -n "$(find -type f -name "wg0-client*.conf")" ]; then
		WG_CLIENT_COUNT=$(expr $(ls -1vq wg0-client* | tail -1 | sed 's/wg0-client-\([0-9]\+\).conf/\1/') + 1)
	fi

    # instructions
	printf "\n\n\n\n\n\n"
	echo -e "\e[1mDO NOT CHANGE DEFAULT VALUES"
	echo -e "\e[2mCLIENT CONFIGURATION"
	echo -e "\e[0mPress Enter to Accept Defaults for Wireguard Client #${WG_CLIENT_COUNT}"
	printf "\n\n"

	CLIENT_WG_IPV4="$(sed "s/\.[0-9]\+$/.$(expr $WG_CLIENT_COUNT + 1)/" <<< $SERVER_WG_IPV4)"
	read -rp "Client's WireGuard IPv4 " -e -i "$CLIENT_WG_IPV4" CLIENT_WG_IPV4

	CLIENT_WG_IPV6="$(sed "s/::[0-9]\+$/::$(expr $WG_CLIENT_COUNT + 1)/" <<< $SERVER_WG_IPV6)"
	read -rp "Client's WireGuard IPv6 " -e -i "$CLIENT_WG_IPV6" CLIENT_WG_IPV6

	# Pi-Hole DNS by default
	CLIENT_DNS_1="$SERVER_WG_IPV4"
	read -rp "First DNS resolver to use for the client: " -e -i "$CLIENT_DNS_1" CLIENT_DNS_1

	CLIENT_DNS_2="$SERVER_WG_IPV6"
	read -rp "Second DNS resolver to use for the client: " -e -i "$CLIENT_DNS_2" CLIENT_DNS_2

	# Generate key pair for the client
	CLIENT_PRIV_KEY=$(wg genkey)
	CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)
	CLIENT_PRE_SHARED_KEY=$(wg genpsk)

	# Read MTU value
	if [ -f "/sys/class/net/${SERVER_WG_NIC}/mtu" ]; then
		CLIENT_MTU="MTU = $(cat /sys/class/net/${SERVER_WG_NIC}/mtu)"
	fi

	# Create client file and add the server as a peer
	echo "[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = $CLIENT_WG_IPV4/24, $CLIENT_WG_IPV6/64
DNS = $CLIENT_DNS_1, $CLIENT_DNS_2
${CLIENT_MTU}

[Peer]
PublicKey = $SERVER_PUB_KEY
PresharedKey = $CLIENT_PRE_SHARED_KEY
Endpoint = $ENDPOINT
AllowedIPs = $SERVER_WG_IPV4/32, $SERVER_WG_IPV6/128" >>"$HOME/$SERVER_WG_NIC-client-$WG_CLIENT_COUNT.conf"

	# Add the client as a peer to the server
	echo -e "\n[Peer]
PublicKey = $CLIENT_PUB_KEY
PresharedKey = $CLIENT_PRE_SHARED_KEY
AllowedIPs = $CLIENT_WG_IPV4/32, $CLIENT_WG_IPV6/128" >>"/etc/wireguard/$SERVER_WG_NIC.conf"

	systemctl restart "wg-quick@$SERVER_WG_NIC"

	echo -e "\nHere is your client config file as a QR Code:"

	qrencode -t ansiutf8 -l L <"$HOME/$SERVER_WG_NIC-client-$WG_CLIENT_COUNT.conf"

	echo "It is also available in $HOME/$SERVER_WG_NIC-client-$WG_CLIENT_COUNT.conf"
    echo "Regenerate this QR Code in the future with this command:"
    echo "sudo cat $(echo $HOME)/$(echo $SERVER_WG_NIC)-client-$(echo $WG_CLIENT_COUNT).conf | qrencode -t ansiutf8 -l L"
}

if [ "$EUID" -ne 0 ]; then
	echo "You need to run this script as root"
	exit 1
fi

if [ "$PWD" != "$HOME" ]; then
        echo "You need to run this script from the root home directory $HOME"
        exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
	echo "OpenVZ is not supported"
	exit
fi

if [ "$(systemd-detect-virt)" == "lxc" ]; then
	echo "LXC is not supported (yet)."
	echo "WireGuard can technically run in an LXC container,"
	echo "but the kernel module has to be installed on the host,"
	echo "the container has to be run with some specific parameters"
	echo "and only the tools need to be installed in the container."
	exit
fi

if [[ $1 == "client" ]]; then
	if [[ -e /etc/wireguard ]]; then
		addClient
		exit 0
	else
		echo "Please install WireGuard first."
		exit 1
	fi
elif [[ -e /etc/wireguard ]]; then
	addClient
	exit 1
fi

# Check OS version
if [[ -e /etc/debian_version ]]; then
	source /etc/os-release
	OS=$ID # debian or ubuntu
elif [[ -e /etc/fedora-release ]]; then
	source /etc/os-release
	OS=$ID
elif [[ -e /etc/centos-release ]]; then
	OS=centos
elif [[ -e /etc/arch-release ]]; then
	OS=arch
else
	echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS or Arch Linux system"
	exit 1
fi

# Install dnsutils to check public IP
if [[ $OS == 'ubuntu' ]]; then
	apt-get update
	apt-get install -y dnsutils
fi

# instructions
printf "\n\n\n\n\n\n"
echo -e "\e[1mDO NOT CHANGE DEFAULT VALUES"
echo -e "\e[2mSERVER CONFIGURATION"
echo -e "\e[0mPress Enter to Accept Defaults"
printf "\n\n"

# Detect public IPv4 address and pre-fill for the user
# dig requires dnsutils to be installed, only the ubuntu condition has this dependency explicitly installed
if type "dig" &> /dev/null; then
	SERVER_PUB_IPV4=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
else
	# Try to detect public IPv4 with third party services when dig is not available
	declare -a ipServices='https://ipinfo.io/ip https://api.ipify.org/ https://ifconfig.me/ip'
	for serv in ${ipServices[@]}; do
		resp=$(curl -s -w "\n%{http_code}" "$serv")
		ec=$?
		resp_code=$(tail -1 <<< "$resp")
		if [ ${ec} -eq 0 ] && [ $resp_code -eq 200 ]; then
		    # Check response for valid IP address
			SERVER_PUB_IPV4=$(grep -oE '[12]{0,1}[0-9]{0,2}\.[12]{0,1}[0-9]{0,2}\.[12]{0,1}[0-9]{0,2}\.[12]{0,1}[0-9]{0,2}' <<< "$resp")
			if [ $? -eq 0 ]; then
				break
			fi
		fi
	done
fi

read -rp "IPv4 public address: " -e -i "$SERVER_PUB_IPV4" SERVER_PUB_IP

# Detect public interface and pre-fill for the user
SERVER_PUB_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
read -rp "Public interface: " -e -i "$SERVER_PUB_NIC" SERVER_PUB_NIC

SERVER_WG_NIC="wg0"
read -rp "WireGuard interface name: " -e -i "$SERVER_WG_NIC" SERVER_WG_NIC

SERVER_WG_IPV4="10.66.66.1"
read -rp "Server's WireGuard IPv4: " -e -i "$SERVER_WG_IPV4" SERVER_WG_IPV4

SERVER_WG_IPV6="fd42:42:42::1"
read -rp "Server's WireGuard IPv6: " -e -i "$SERVER_WG_IPV6" SERVER_WG_IPV6

# Generate random number within private ports range
SERVER_PORT="51515"
read -rp "Server's WireGuard port: " -e -i "$SERVER_PORT" SERVER_PORT

# Install WireGuard tools and module
if [[ $OS == 'ubuntu' ]]; then
	apt-get install -y software-properties-common
	add-apt-repository -y ppa:wireguard/wireguard
	apt-get update
	apt-get install -y "linux-headers-$(uname -r)"
    apt-get install -y wireguard iptables resolvconf qrencode
elif [[ $OS == 'debian' ]]; then
	echo "deb http://deb.debian.org/debian/ unstable main" >/etc/apt/sources.list.d/unstable.list
	printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' >/etc/apt/preferences.d/limit-unstable
	apt update
	apt-get install -y "linux-headers-$(uname -r)"
	apt-get install -y wireguard iptables resolvconf qrencode
	apt-get install -y bc # mitigate https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=956869
elif [[ $OS == 'fedora' ]]; then
	if [[ $VERSION_ID -lt 32 ]]; then
		dnf install -y dnf-plugins-core
		dnf copr enable -y jdoss/wireguard
		dnf install -y wireguard-dkms
	fi
	dnf install -y wireguard-tools iptables qrencode
elif [[ $OS == 'centos' ]]; then
	curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
	yum -y install epel-release
	yum -y install wireguard-dkms wireguard-tools iptables qrencode
elif [[ $OS == 'arch' ]]; then
	pacman -S --noconfirm linux-headers
	pacman -S --noconfirm wireguard-tools iptables wireguard-arch qrencode
fi

# Make sure the directory exists (this does not seem the be the case on fedora)
mkdir /etc/wireguard >/dev/null 2>&1

chmod 600 -R /etc/wireguard/
# On CentOS and Fedore wg-quick service won't find the config without execution rights on the folder
if [[ $OS =~ (fedora|centos) ]]; then
	chmod 700 /etc/wireguard
fi

SERVER_PRIV_KEY=$(wg genkey)
SERVER_PUB_KEY=$(echo "$SERVER_PRIV_KEY" | wg pubkey)

# Save WireGuard settings
echo "SERVER_PUB_IP=$SERVER_PUB_IP
SERVER_PUB_NIC=$SERVER_PUB_NIC
SERVER_WG_NIC=$SERVER_WG_NIC
SERVER_WG_IPV4=$SERVER_WG_IPV4
SERVER_WG_IPV6=$SERVER_WG_IPV6
SERVER_PORT=$SERVER_PORT
SERVER_PRIV_KEY=$SERVER_PRIV_KEY
SERVER_PUB_KEY=$SERVER_PUB_KEY" >/etc/wireguard/params

source /etc/wireguard/params

# Add server interface
echo "[Interface]
Address = $SERVER_WG_IPV4/24,$SERVER_WG_IPV6/64
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_PRIV_KEY" >"/etc/wireguard/$SERVER_WG_NIC.conf"

if [ -x "$(command -v firewall-cmd)" ]; then
	FIREWALLD_IPV4_ADDRESS=$(echo "$SERVER_WG_IPV4" | cut -d"." -f1-3)".0"
	FIREWALLD_IPV6_ADDRESS=$(echo "$SERVER_WG_IPV6" | sed 's/:[^:]*$/:0/')
	echo "PostUp = firewall-cmd --add-port $SERVER_PORT/udp && firewall-cmd --add-rich-rule='rule family=ipv4 source address=$FIREWALLD_IPV4_ADDRESS/24 masquerade' && firewall-cmd --add-rich-rule='rule family=ipv6 source address=$FIREWALLD_IPV6_ADDRESS/24 masquerade'
PostDown = firewall-cmd --remove-port $SERVER_PORT/udp && firewall-cmd --remove-rich-rule='rule family=ipv4 source address=$FIREWALLD_IPV4_ADDRESS/24 masquerade' && firewall-cmd --remove-rich-rule='rule family=ipv6 source address=$FIREWALLD_IPV6_ADDRESS/24 masquerade'" >>"/etc/wireguard/$SERVER_WG_NIC.conf"
else
	echo "PostUp = iptables -A FORWARD -i $SERVER_WG_NIC -j ACCEPT; iptables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE; ip6tables -A FORWARD -i $SERVER_WG_NIC -j ACCEPT; ip6tables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
PostDown = iptables -D FORWARD -i $SERVER_WG_NIC -j ACCEPT; iptables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE; ip6tables -D FORWARD -i $SERVER_WG_NIC -j ACCEPT; ip6tables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE" >>"/etc/wireguard/$SERVER_WG_NIC.conf"
fi

# Enable routing on the server
echo "net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >/etc/sysctl.d/wg.conf

sysctl --system

systemctl start "wg-quick@$SERVER_WG_NIC"
systemctl enable "wg-quick@$SERVER_WG_NIC"

# Check if WireGuard is running
systemctl is-active --quiet "wg-quick@$SERVER_WG_NIC"
WG_RUNNING=$?

# Warn user about kernel version mismatch with headers
if [[ $OS =~ (fedora|centos) ]] && [[ $WG_RUNNING -ne 0 ]]; then
	echo -e "\nWARNING: WireGuard does not seem to be running."
	echo "Due to kernel mismatch issues on $OS, WireGuard might work if your system is out of date."
	echo "You can check if WireGuard is running with: systemctl status wg-quick@$SERVER_WG_NIC"
	echo 'If you get something like "Cannot find device wg0", please run:'
	if [[ $OS == 'fedora' ]]; then
		echo "dnf update -y && reboot"
	elif [[ $OS == 'centos' ]]; then
		echo "yum update -y && reboot"
	fi
fi

# install pihole if it has not been installed
if ! type "pihole" &> /dev/null; then
	curl -sSL https://install.pi-hole.net | bash
	ec=$?
	if [ $ec -ne 0 ]; then
		printf "\n\e[1mERROR \e[0m- Failed to install PiHole!\n"
		exit ${ec}
	fi
fi

# use client configurations to determine if this is the first run, and apply preferred initial configurations
if [[ ! $(ls -A wg0-client* 2>/dev/null) ]]; then
	pihole -a -i local

	# instructions
	printf "\n\n\n\n\n\n"
	echo -e "\e[2mPIHOLE CONFIGURATION"
	echo -e "\e[0mSet the Admin Password for your Pi-Hole Interface"
	printf "\n\n"

	pihole -a -p
fi

addClient

# The MIT License (MIT)

# Copyright (c) 2020 Rajan Patel

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Notice for Software Components Licensed Under the MIT License.

# wireguard-install Copyright (c) 2019 angristan (Stanislas Lange)
