# menambahkan iptablase
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# ping semua node
ping google.com -c 2
