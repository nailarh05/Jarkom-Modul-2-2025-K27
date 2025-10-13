nano /etc/bind/k27/k27.com
#menambahkan 
$TTL    604800          ; Waktu cache default (detik)
@       IN      SOA     ns1.k27.com. root.k27.com. (
                        2025100401 ; Serial (format YYYYMMDDXX)
                        604800     ; Refresh (1 minggu)
                        86400      ; Retry (1 hari)
                        2419200    ; Expire (4 minggu)
                        604800 )   ; Negative Cache TTL
;

@               IN      A       10.77.3.2

@               IN      NS      ns1.k27.com.
@               IN      NS      ns2.k27.com.
ns1             IN      A        10.77.3.3
ns2             IN      A        10.77.3.4

eonwe           IN      A       10.77.1.1
earendll        IN      A       10.77.1.2
elwing          IN      A       10.77.1.3
cirdan          IN      A       10.77.2.2
elrond          IN      A       10.77.2.3
maglor          IN      A       10.77.2.4
sirion          IN      A       10.77.3.2
tirion          IN      A       10.77.3.3
valmar          IN      A       10.77.3.4
lidion          IN      A       10.77.3.5
vinglot         IN      A       10.77.3.6

#nge restard
 service bind9 restart
 #mencoba mengenode 
dig earendil.k27.com
dig sirion.k27.com
