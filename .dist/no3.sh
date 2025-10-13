#ping antar timur dan barat tp sebelum itu kita harus ngejalanin 
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth2 -j ACCEPT

#ping antar node barat ke timur
ping 10.77.2.2  
ping 10.77.3.2 
