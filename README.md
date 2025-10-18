# Jarkom-Modul-2-2025-K27

**Praktikum Jaringan Komputer 2025**  
Topik: DNS, Routing, NAT, Web Server, dan Reverse DNS  

---

## 👥 Anggota Kelompok
| Nama | NRP |
|------|------|
| Naila Raniyah Hanan | 5027241078|
| Naufan Andi | 50272410 |

---

## 🧠 Deskripsi Umum

Pada praktikum modul 2 ini, peserta diminta membangun sistem jaringan bertema **War of Wrath** yang terdiri dari beberapa node (router, DNS master-slave, web server, dan client).  
Tujuan praktikum ini adalah untuk memahami cara kerja **DNS server (master & slave)**, **CNAME**, **reverse DNS**, serta **implementasi web statis & dinamis**.

---

## 🗺️ Topologi

<img width="707" height="596" alt="Screenshot 2025-10-18 101453" src="https://github.com/user-attachments/assets/23abe9b8-036f-4913-86a9-970fb18b15aa" />


---

## ⚙️ Soal & Penyelesaian

---

### **1. Konfigurasi Jaringan di Seluruh Node**

Lakukan konfigurasi IP untuk setiap node sesuai pembagian subnet dan koneksi pada topologi War of Wrath.

#### 🔹 Jawaban & Tata Cara
1. Buka file konfigurasi jaringan:
   ```bash
   nano /etc/network/interfaces
   ```
2. Atur IP pada tiap node, contoh untuk **Eonwe (Router)**:
   ```bash
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
   ```
3. Aktifkan IP forwarding:
   ```bash
    echo "nameserver 192.168.122.1" > /etc/resolv.conf
   ```
4. Restart service:
   ```bash
   service networking restart
   ```

---

### **2. Konfigurasi NAT agar Semua Node Bisa Akses Internet**

Eonwe sebagai router harus bisa menghubungkan semua node internal ke internet.

#### 🔹 Jawaban & Tata Cara
1. Jalankan perintah NAT:
   ```bash
     iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.77.0.0/16
   ```
2. Tes koneksi dari node klien:
   ```bash
     ping google.com
   ```
3. Jika berhasil, maka semua node sudah dapat akses internet.

---

### **3. Konfigurasi Routing Internal**

#### 🔹 Soal
Pastikan setiap subnet dapat saling berkomunikasi melalui Eonwe.

#### 🔹 Jawaban & Tata Cara
1. Tambahkan rule forwarding di Eonwe:
   ```bash
    iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT
    iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT
    iptables -A FORWARD -i eth1 -o eth3 -j ACCEPT
    iptables -A FORWARD -i eth3 -o eth1 -j ACCEPT
    iptables -A FORWARD -i eth2 -o eth3 -j ACCEPT
    iptables -A FORWARD -i eth3 -o eth2 -j ACCEPT

   ```
2. Tesnode elwing atau earendil :
   ```bash
   ping 10.77.2.2 (ping cirdan) 
   ping 10.77.3.2 (ping sirion)
   ```

---

### **4. Konfigurasi DNS Master dan Slave**

#### 🔹 Soal
Buat sistem DNS utama (Master) dan DNS cadangan (Slave).
DNS Master akan menyimpan data zona utama (k27.com), sedangkan DNS Slave akan menyalin data tersebut secara otomatis melalui zone transfer agar tetap bisa melayani query jika DNS Master mati.

#### 🔹 Jawaban & Tata Cara
**A. Konfigurasi di Node Tirion (DNS Master)**
1. Install paket BIND9 dan DNS Utilities:
   ```bash
    apt-get update
    apt-get install -y bind9 dnsutils
   ```  
2.Edit file konfigurasi global named.conf.options:
   ```bash
   nano > /etc/bind/named.conf.options
   ```
   Tambahkan: 
   ```bash
    options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };

    allow-transfer { 10.77.3.4; };  
    notify yes;                      
    listen-on { any; };

    dnssec-validation auto;
    listen-on-v6 { any; };
    };
   ```
3. Atur file named.conf.local untuk mendefinisikan zona k27.com:
   ```bash
   nano /etc/bind/named.conf.local
   ```
   Tambahkan:
   ```
   zone "k27.com" {
    type master;
    file "/etc/bind/zones/db.k27.com";
    allow-transfer { 10.77.3.4; };   # alamat IP Valmar (slave)
    also-notify { 10.77.3.4; };      # kirim notifikasi ke slave
    notify yes;
    };

   ```
4. Buat direktori dan file zona
   ```bash
    mkdir -p /etc/bind/zones
    cat > /etc/bind/zones/db.k27.com
   ```
   Isi:
   ```
      $TTL    604800
      @       IN      SOA     ns1.k27.com. root.k27.com. (
                2025100401 ; Serial (YYYYMMDDXX)
                604800     ; Refresh (1 minggu)
                86400      ; Retry (1 hari)
                2419200    ; Expire (4 minggu)
                604800 )   ; Negative Cache TTL

    @       IN      A       10.77.3.2
    @       IN      NS      ns1.k27.com.
    @       IN      NS      ns2.k27.com.
    ns1     IN      A       10.77.3.3
    ns2     IN      A       10.77.3.4

   ```
   5. Aktifkan dan restart layanan:
   ```bash
    ln -s /etc/init.d/named /etc/init.d/bind9
    service bind9 restart
   ```
 **Konfigurasi di Node Valmar (DNS Slave)**
 1. Install paket BIND9 dan DNS Utilities:
   ```bash
    apt-get update
    apt-get install -y bind9 dnsutils
   ```  
 2.Edit file konfigurasi global named.conf.options:
   ```bash
   nano > /etc/bind/named.conf.options
   ```
   Tambahkan: 
   ```bash
    options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };

    allow-transfer { 10.77.3.4; };  
    notify yes;                      
    listen-on { any; };

    dnssec-validation auto;
    listen-on-v6 { any; };
    };
   ```
3. Atur file named.conf.local untuk mendefinisikan zona k27.com:
   ```bash
   nano /etc/bind/named.conf.local
   ```
   Tambahkan:
   ```
   zone "k27.com" {
    type slave;
    file "/etc/bind/zones/db.k27.com";
    masters { 10.77.3.3; };   # IP Tirion sebagai DNS Master
    };

   ```
4. Periksa konfigurasi dan jalankan ulang layanan
   ```bash
    named-checkconf
    service named restart

   ```
 
**Penguji dari client**
Lakukan dari client mana pun (yang sudah diarahkan ke DNS master/slave):
```bash
   dig k27.com
   dig ns1.k27.com
   dig ns2.k27.com

```
---

### **5. Konfigurasi DNS Slave pada Valmar**

#### 🔹 Soal
Buat DNS slave server pada **Valmar** untuk zona `k27.com`.

#### 🔹 Jawaban & Tata Cara
1. Pada **Tirion**, tambahkan izin transfer di `/etc/bind/named.conf.local`:
   ```
   allow-transfer { 10.77.2.3; };
   also-notify { 10.77.2.3; };
   ```
2. Pada **Valmar**, tambahkan zona slave:
   ```
   zone "k25.com" {
       type slave;
       masters { 10.77.2.2; };
       file "/var/lib/bind/k25.com";
   };
   ```
3. Restart kedua server:
   ```bash
   service bind9 restart
   ```
4. Tes di klien:
   ```bash
   dig @10.77.2.3 k27.com
   ```

---

### **6. Menambahkan Subdomain dan CNAME**

#### 🔹 Soal
Tambahkan subdomain dan CNAME berikut:
- `www.k27.com` mengarah ke `sirion.k27.com`
- `static.k27.com` mengarah ke `lindon.k27.com`
- `app.k27.com` mengarah ke `vingilot.k27.com`

#### 🔹 Jawaban & Tata Cara
Edit file `/etc/bind/jarkom/db.k27.com` di Tirion:
```
sirion  IN  A   10.77.3.2
lindon  IN  A   10.77.3.3
vingilot IN A   10.77.3.4

www     IN  CNAME sirion.k27.com.
static  IN  CNAME lindon.k27.com.
app     IN  CNAME vingilot.k27.com.
```

---

### **7. Konfigurasi Reverse DNS**

#### 🔹 Soal
Buat reverse zone untuk subnet DMZ (10.77.3.0/24).

#### 🔹 Jawaban & Tata Cara
1. Tambahkan pada `named.conf.local`:
   ```
   zone "3.77.10.in-addr.arpa" {
       type master;
       file "/etc/bind/jarkom/db.3.77.10.in-addr.arpa";
   };
   ```
2. Buat file zona:
   ```bash
   cp /etc/bind/db.local /etc/bind/jarkom/db.3.77.10.in-addr.arpa
   ```
3. Tambahkan PTR record:
   ```
   2 IN PTR sirion.k27.com.
   3 IN PTR lindon.k27.com.
   4 IN PTR vingilot.k27.com.
   ```

---

### **8. Konfigurasi Web Server Statis**

#### 🔹 Soal
Lindon digunakan untuk web server statis `static.k27.com` menggunakan Nginx.

#### 🔹 Jawaban & Tata Cara
1. Instal Nginx:
   ```bash
   apt install nginx -y
   ```
2. Buat direktori web:
   ```bash
   mkdir -p /var/www/static.k27
   echo "Welcome to static.k27.com" > /var/www/static.k25/index.html
   ```
3. Konfigurasi Nginx:
   ```bash
   nano /etc/nginx/sites-available/static.k25
   ```
   ```
   server {
       listen 80;
       server_name static.k27.com;

       root /var/www/static.k27;
       index index.html;
       autoindex on;
   }
   ```
4. Aktifkan situs:
   ```bash
   ln -s /etc/nginx/sites-available/static.k27 /etc/nginx/sites-enabled/
   service nginx restart
   ```

---

### **9. Konfigurasi Web Server Dinamis (PHP)**

#### 🔹 Soal
Vingilot digunakan untuk web dinamis `app.k27.com` menggunakan Nginx + PHP-FPM.

#### 🔹 Jawaban & Tata Cara
1. Instal paket:
   ```bash
   apt install nginx php-fpm -y
   ```
2. Buat folder:
   ```bash
   mkdir -p /var/www/app.k25
   echo "<?php phpinfo(); ?>" > /var/www/app.k27/index.php
   echo "<?php echo 'About page'; ?>" > /var/www/app.k25/about.php
   ```
3. Konfigurasi Nginx:
   ```
   server {
       listen 80;
       server_name app.k27.com;

       root /var/www/app.k27;
       index index.php;

       location / {
           try_files $uri $uri/ /index.php?$query_string;
       }

       location ~ \.php$ {
           include snippets/fastcgi-php.conf;
           fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
       }
   }
   ```
4. Aktifkan situs:
   ```bash
   ln -s /etc/nginx/sites-available/app.k25 /etc/nginx/sites-enabled/
   service nginx restart
   ```

---

### **10. Pengujian Akhir**

#### 🔹 Soal
Lakukan pengujian untuk memastikan semua fitur berjalan dengan benar.

#### 🔹 Jawaban & Tata Cara
- **Ping domain utama**
  ```bash
  ping k27.com
  ```
- **Test DNS slave**
  ```bash
  dig @10.77.2.3 k27.com
  ```
- **Test reverse DNS**
  ```bash
  dig -x 10.77.3.2
  ```
- **Test web statis**
  ```bash
  curl static.k27.com
  ```
- **Test web dinamis**
  ```bash
  curl app.k27.com
  curl app.k27.com/about
  ```

Semua domain dan subdomain harus berhasil di-resolve dan ditampilkan sesuai konfigurasi.

---

## 💡 Kesimpulan
Pada modul ini, seluruh sistem DNS dan web server berhasil dikonfigurasi secara lengkap, mulai dari routing, NAT, master-slave DNS, reverse DNS, hingga hosting web statis dan dinamis.

---

## 📎 Lampiran
Berisi screenshot hasil pengujian (`ping`, `dig`, `curl`) dan isi file konfigurasi penting:
- `/etc/network/interfaces`
- `/etc/bind/named.conf.local`
- `/etc/bind/jarkom/db.k25.com`
- `/etc/nginx/sites-available/...`
