#Eonwe
auto eth0
iface eth0 inet dhcp
auto eth1
iface eth1 inet static
	address 10.77.1.1
	netmask 255.255.255.0
auto eth2
iface eth2 inet static
	address 10.77.2.1
	netmask 255.255.255.0
auto eth3
iface eth2 inet static
	address 10.77.3.1
	netmask 255.255.255.0
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
	up apt-get update
	up sysctl -w net.ipv4.ip_forward=1
	up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#Earendil
auto eth0
iface eth0 inet static
	address 10.77.1.2
	netmask 255.255.255.0
	gateway 10.77.1.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf

#Elwing 
auto eth0
iface eth0 inet static
	address 10.77.1.3
	netmask 255.255.255.0
	gateway 10.77.1.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf
 
# Cirdan 
auto eth0
iface eth2 inet static
	address 10.77.2.2
	netmask 255.255.255.0
	getway 10.77.2.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf

#Elrond
auto eth0
iface eth0 inet static
	address 10.77.2.3
	netmask 255.255.255.0
	gateway 10.77.2.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf

#Malgor
auto eth0
iface eth0 inet static
    address 10.77.2.4
    netmask 255.255.255.0
    gateway 10.77.2.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf

#Siriron
auto eth0
iface eth0 inet static
    address 10.77.3.2
    netmask 255.255.255.0
    gateway 10.77.3.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
#Tirion
auto eth0
iface eth0 inet static
    address 10.77.3.3
    netmask 255.255.255.0
    gateway 10.77.3.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf

#Valmar 
auto eth0
iface eth0 inet static
    address 10.77.3.4
    netmask 255.255.255.0
    gateway 10.77.3.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf

#lindion 
auto eth0
iface eth0 inet static
    address 10.77.3.5
    netmask 255.255.255.0
    gateway 10.77.3.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf

#Vingilot
auto eth0
iface eth0 inet static
    address 10.77.3.6
    netmask 255.255.255.0
    gateway 10.77.3.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf

