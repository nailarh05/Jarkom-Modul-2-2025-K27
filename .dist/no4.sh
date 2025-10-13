#instalasi bind
 apt-get update
 apt-get install bind9 -y
 ln -s /etc/init.d/named /etc/init.d/bind9
 # buat domain
 nano /etc/bind/named.conf.local
 mkdir /etc/bind/k27
 cp /etc/bind/zone.template /etc/bind/k27/k27.c
 nano /etc/bind/k27/k27.com

 #chek eror apa nggak 
 named -g

 #jalankan 
  ping ns1.k27.com
  ping ns2.k27.com
  ping k27.com