# Jarkom-Modul-2-2025-K27

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
<img width="645" height="534" alt="image" src="https://github.com/user-attachments/assets/b3779342-9874-4db3-a63c-480b7cceb62a" />

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
 ** B. Konfigurasi di Node Valmar (DNS Slave)**
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
<img width="670" height="632" alt="image" src="https://github.com/user-attachments/assets/fa86ca2c-0752-43e6-8016-3dbd3186862e" />

---

### **5. Penamaan Hostname dan Domain Setiap Node**

#### 🔹 Soal
“Nama memberi arah,” kata Eonwe. Namai semua tokoh (hostname) sesuai glosarium, eonwe, earendil, elwing, cirdan, elrond, maglor, sirion, tirion, valmar, lindon, vingilot, dan verifikasi bahwa setiap host mengenali dan menggunakan hostname tersebut secara system-wide. Buat setiap domain untuk masing masing node sesuai dengan namanya (contoh: eru.<xxxx>.com) dan assign IP masing-masing juga. Lakukan pengecualian untuk node yang bertanggung jawab atas ns1 dan ns2


#### 🔹 Jawaban & Tata Cara
1. Mengatur Hostname di Setiap Node:
   Perintah ini memastikan nama host tersimpan permanen di /etc/hostname dan         aktif secara langsung.
   ```
   # Node Eonwe
   echo "eonwe" > /etc/hostname
   hostname -F /etc/hostname

   # Node Earendil
   echo "earendil" > /etc/hostname
   hostname -F /etc/hostname

   # Node Elwing
   echo "elwing" > /etc/hostname
   hostname -F /etc/hostname

   # Node Cirdan
   echo "cirdan" > /etc/hostname
   hostname -F /etc/hostname

   # Node Elrond
   echo "elrond" > /etc/hostname
   hostname -F /etc/hostname

   # Node Maglor
   echo "maglor" > /etc/hostname
   hostname -F /etc/hostname

   # Node Sirion
   echo "sirion" > /etc/hostname
   hostname -F /etc/hostname

   # Node Tirion
   echo "tirion" > /etc/hostname
   hostname -F /etc/hostname

   # Node Valmar
   echo "valmar" > /etc/hostname
   hostname -F /etc/hostname

   # Node Lindon
   echo "lindon" > /etc/hostname
   hostname -F /etc/hostname

   # Node Vingilot
   echo "vingilot" > /etc/hostname
   hostname -F /etc/hostname

   ```
2. Menambahkan Record Domain untuk Setiap Node di DNS Master (Tirion):
   mendaftarkan semua node agar bisa diakses melalui domain <nama>.k27.com.
  ```bash
   nano /etc/bind/zones/db.k27.com
   ```
   Tambahkan:
   ```
   TTL    604800
   @       IN      SOA     ns1.k27.com. admin.k27.com. (
                              2025101103         ; Serial (naikkan!)
                              604800         ; Refresh
                              86400         ; Retry
                              2419200         ; Expire
                              604800 )       ; Negative Cache TTL

   @               IN      A       10.77.3.2

   @               IN      NS      ns1.k27.com.
   @               IN      NS      ns2.k27.com.
   ns1             IN      A        10.77.3.3
   ns2             IN      A        10.77.3.4

   eonwe.k27.com.      IN      A       10.77.1.1
   earendil.k27.com.   IN      A       10.77.1.2
   elwing.k27.com.     IN      A       10.77.1.3
   cirdan.k27.com.     IN      A       10.77.2.2
   elrond.k27.com.     IN      A       10.77.2.3
   maglor.k27.com.     IN      A       10.77.2.4
   sirion.k27.com.     IN      A       10.77.3.2
   lindon.k27.com.     IN      A       10.77.3.5
   vingilot.k27.com.   IN      A       10.77.3.6

   ```
3. Verifikasi Zona dan Restart DNS:
   Setelah menulis file zona, periksa apakah formatnya benar dan restart layanan     DNS
   ```bash
   service bind9 restart
   ```
4. Tes di node klien:
   Uji apakah hostname dan domain sudah bisa dikenali
   ```bash
   dig erendil.k27.com
    dig sirion.k27.com
   ```
   <img width="683" height="388" alt="image" src="https://github.com/user-attachments/assets/529906d0-acbe-4aed-a374-b707187aa416" />
   <img width="630" height="406" alt="image" src="https://github.com/user-attachments/assets/d33c6a2f-1d99-4809-b85b-0c7bc6afab75" />



---

### **6. Verifikasi Zone Transfer (Sinkronisasi antara ns1 dan ns2)**

#### 🔹 Soal
Lonceng Valmar berdentang mengikuti irama Tirion. Pastikan zone transfer berjalan, Pastikan Valmar (ns2) telah menerima salinan zona terbaru dari Tirion (ns1). Nilai serial SOA di keduanya harus sama

#### 🔹 Jawaban & Tata Cara

Cek SOA Record di Tirion (ns1):
```
dig @10.77.3.3 k27.com SOA
```
<img width="645" height="275" alt="image" src="https://github.com/user-attachments/assets/4ab96339-0166-4c4c-929b-dccb3b16ff27" />
<img width="651" height="294" alt="image" src="https://github.com/user-attachments/assets/d3cd5623-d04e-4b9a-8ae9-20c23b825ba0" />


Cek SOA Record di Valmar (ns2
```
dig @10.77.3.4 k27.com SOA

```
<img width="657" height="387" alt="image" src="https://github.com/user-attachments/assets/5ecc1226-7937-4b9b-b850-7bf99b30f882" />

---

### **7. Konfigurasi Reverse Zone (Pencarian Balik IP Address)**

#### 🔹 Soal

Peta kota dan pelabuhan dilukis. Sirion sebagai gerbang, Lindon sebagai web statis, Vingilot sebagai web dinamis. Tambahkan pada zona <xxxx>.com A record untuk sirion.<xxxx>.com (IP Sirion), lindon.<xxxx>.com (IP Lindon), dan vingilot.<xxxx>.com (IP Vingilot). Tetapkan CNAME :
www.<xxxx>.com → sirion.<xxxx>.com, 
static.<xxxx>.com → lindon.<xxxx>.com, dan 
app.<xxxx>.com → vingilot.<xxxx>.com. 
Verifikasi dari dua klien berbeda bahwa seluruh hostname tersebut ter-resolve ke tujuan yang benar dan konsisten.

#### 🔹 Jawaban & Tata Cara
1. Konfigurasi di Node Tirion:
   ```bash
   $TTL    604800
   @       IN      SOA     ns1.k27.com. admin.k27.com. (
                              2025101103         ; Serial (naikkan!)
                              604800         ; Refresh
                              86400         ; Retry
                              2419200         ; Expire
                              604800 )       ; Negative Cache TTL

   @               IN      A       10.77.3.2

   @               IN      NS      ns1.k27.com.
   @               IN      NS      ns2.k27.com.
   ns1             IN      A        10.77.3.3
   ns2             IN      A        10.77.3.4

   eonwe.k27.com.      IN      A       10.77.1.1
   earendil.k27.com.   IN      A       10.77.1.2
   elwing.k27.com.     IN      A       10.77.1.3
   cirdan.k27.com.     IN      A       10.77.2.2
   elrond.k27.com.     IN      A       10.77.2.3
   maglor.k27.com.     IN      A       10.77.2.4
   sirion.k27.com.     IN      A       10.77.3.2
   lindon.k27.com.     IN      A       10.77.3.5
   vingilot.k27.com.   IN      A       10.77.3.6


   www.k27.com.        IN      CNAME   sirion.k27.com.
   static.k27.com.     IN      CNAME   lindon.k27.com.
   app.k27.com.        IN      CNAME   vingilot.k27.com

   ```
   Periksa dan restart layanan BIND:
   ```bash
   named-checkzone k27.com /etc/bind/zones/db.k27.com
   service named restart
   ```
2. Pengujian dari Node Manapun:
   ```bash
   dig www.k27.com
   dig static.k27.com
   dig app.k27.com

   ```
   <img width="662" height="424" alt="image" src="https://github.com/user-attachments/assets/0b0cbc3c-d5fb-44fb-b343-8ee83d8b6454" />
   <img width="642" height="390" alt="image" src="https://github.com/user-attachments/assets/63f5302f-c394-469b-b470-9314c8203fb9" />


---

### **8.Reverse Zone di ns1 (Tirion) dan ns2 (Valmar)**

#### 🔹 Soal
Setiap jejak harus bisa diikuti. Di Tirion (ns1) deklarasikan satu reverse zone untuk segmen DMZ tempat Sirion, Lindon, Vingilot berada. Di Valmar (ns2) tarik reverse zone tersebut sebagai slave, isi PTR untuk ketiga hostname itu agar pencarian balik IP address mengembalikan hostname yang benar, lalu pastikan query reverse untuk alamat Sirion, Lindon, Vingilot dijawab authoritative.
trs la
#### 🔹 Jawaban & Tata Cara
1. Konfigurasi di Node Tirion (ns1):
   ```bash
   cat > /etc/bind/named.conf.local
   ```
   tambhkan :
   ```bash

   $TTL    604800
   @       IN      SOA     ns1.k27.com. admin.k27.com. (
                              2025101101         ; Serial
                              604800         ; Refresh
                              86400         ; Retry
                              2419200         ; Expire
                              604800 )       ; Negative Cache TTL
   ;
   ; Name Servers
   @       IN      NS      ns1.k27.com.
   @       IN      NS      ns2.k27.com.

   ; PTR Records
   2       IN      PTR     sirion.k27.com.
   3       IN      PTR     ns1.k27.com.
   4       IN      PTR     ns2.k27.com.
   5       IN      PTR     lindon.k27.com.
   6       IN      PTR     vingilot.k27.com.

   ```
   Periksa validitas dan restart layanan BIND :
   ```bash
   service named restart
   ```
2. Konfigurasi di Node Valmar (ns2)
   ```bash
     mkdir -p /etc/bind/zones
   cat > /etc/bind/named.conf.local
   ```
   ```
   zone "k27.com" {
    type slave;
    file "db.k27.com";
    masters { 10.77.3.3; };
   };

   zone "3.77.10.in-addr.arpa" {
    type slave;
    file "db.10.77.3";
    masters { 10.77.3.3; };
   };
   ```
   Periksa validitas dan restart layanan BIND :
   ```bash
   service named restart
   ```
3. Pengujian dari Node Manapun:
   ```bash
   dig -x 10.77.3.2
   dig -x 10.77.3.5
   dig -x 10.77.3.6

   ```
<img width="646" height="305" alt="image" src="https://github.com/user-attachments/assets/b4cd8a68-fd29-4c68-b536-573fa1f7b734" />
<img width="678" height="375" alt="image" src="https://github.com/user-attachments/assets/74983896-b027-41d1-bcbb-8a2e76aee46d" />
<img width="668" height="314" alt="image" src="https://github.com/user-attachments/assets/6831f5d0-b79d-460d-8307-2133a2b3d84f" />


---

### **9. Konfigurasi Web Statis dengan Autoindex di Node Lindon**

#### 🔹 Soal
Lampion Lindon dinyalakan. Jalankan web statis pada hostname static.<xxxx>.com dan buka folder arsip /annals/ dengan autoindex (directory listing) sehingga isinya dapat ditelusuri. Akses harus dilakukan melalui hostname, bukan IP..

#### 🔹 Jawaban & Tata Cara
1. Instalasi dan Persiapan Nginx:
   ```bash
   apt-get update
   apt-get install -y nginx

   ```
2. Membuat Konfigurasi Virtual Host static.k27.com : 
   ```bash
     cat > /etc/nginx/sites-available/static.k27.com
   ```
   Tambahkan
   ```
   server {
    listen 80;
    server_name static.k27.com lindon.k27.com;
    
    root /var/www/static;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location /annals/ {
        alias /var/www/static/annals/;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }
   }

   ```
3. Mengaktifkan Virtual Host dan Struktur Folder:
   ```
   ln -sf /etc/nginx/sites-available/static.k27.com /etc/nginx/sites-enabled/
   rm -f /etc/nginx/sites-enabled/default
   mkdir -p /var/www/static/annals

   ```
4. Uji Konfigurasi dan Restart Nginx :
   ```bash
     nginx -t
   service nginx restart

   ```
5. Pengujian dari Node Manapun
   Lakukan pengujian akses melalui hostname, bukan IP:
   ```
   curl http://static.k27.com
   curl http://static.k27.com/annals/

   ```
<img width="662" height="559" alt="image" src="https://github.com/user-attachments/assets/ce44f26a-a64f-4320-92c6-bff4010e2a5a" />
<img width="650" height="597" alt="image" src="https://github.com/user-attachments/assets/8f7ff9a2-a610-485f-8036-a880363f2b0d" />


---

### **10. Menjalankan Web Dinamis (PHP-FPM) di Node Vingilot**

#### 🔹 Soal
Vingilot mengisahkan cerita dinamis. Jalankan web dinamis (PHP-FPM) pada hostname app.<xxxx>.com dengan beranda dan halaman about, serta terapkan rewrite sehingga /about berfungsi tanpa akhiran .php. Akses harus dilakukan melalui hostname.

#### 🔹 Jawaban & Tata Cara
1. Instalasi Web Server Nginx dan PHP-FPM
  ```bash
  apt-get update
  apt-get install -y nginx php8.4-fpm

  ```
2. Konfigurasi Virtual Host app.k27.com
  ```bash
  cat > /etc/nginx/sites-available/app.k27.com
  ```
   tambahkan :
  ```bash
 server {
    listen 80;
    server_name app.k27.com vingilot.k27.com;
    
    root /var/www/app;
    index index.php;
    
    location / {
        try_files $uri $uri/ @rewrite;
    }
    
    location @rewrite {
        rewrite ^/(.+)$ /$1.php last;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.ht {
        deny all;
    }
      }

  ```
3. Aktivasi Virtual Host dan Pembuatan Direktori Web
  ```bash
  ln -sf /etc/nginx/sites-available/app.k27.com /etc/nginx/sites-enabled/
  rm -f /etc/nginx/sites-enabled/default
  mkdir -p /var/www/app

  ```
4. Membuat Halaman Utama (index.php)
  ```bash
  cat > /var/www/app/index.php << 'EOF'
   <!DOCTYPE html>
   <html>
   <head>
       <title>Vingilot - Dynamic Application</title>
       <style>
           body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        h1 { margin-bottom: 10px; }
        .info { background: rgba(255,255,255,0.1); padding: 15px; border-radius:    5px; margin: 20px 0; }
        a { color: #ffd700; }
    </style>
</head>
<body>
    <h1>Welcome to Vingilot</h1>
    <p>The ship that sails through dynamic waters</p>
    
    <div class="info">
        <h2>Server Information</h2>
        <p><strong>Server Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
        <p><strong>Client IP:</strong> <?php echo $_SERVER['REMOTE_ADDR']; ?></p>
        <p><strong>User Agent:</strong> <?php echo $_SERVER['HTTP_USER_AGENT']; ?>   </p>
    </div>
    
    <p><a href="/about">Learn more about Vingilot</a></p>
   </body>
   </html>

  ```
5. Membuat Halaman About (about.php)
   ```bash
   cat > /var/www/app/about.php 
   ```
   tambahkan :
   
   ```
   <!DOCTYPE html>
   <html>
   <head>
    <title>About Vingilot</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
        }
        h1 { margin-bottom: 10px; }
        .content { background: rgba(255,255,255,0.1); padding: 20px; border-               radius: 5px; margin: 20px 0; }
        a { color: #ffd700; }
    </style>
   </head>
   <body>
    <h1>About Vingilot</h1>
    
    <div class="content">
        <h2>The Star Ship</h2>
        <p>Vingilot adalah kapal yang dipandu oleh Earendil, membawa Silmaril          melintasi langit sebagai bintang paling terang.</p>
        
        <h3>Technical Details</h3>
        <p><strong>Powered by:</strong> PHP <?php echo phpversion(); ?></p>
        <p><strong>Server:</strong> Nginx</p>
        <p><strong>Current Path:</strong> <?php echo $_SERVER['REQUEST_URI']; ?>         </p>
        <p><strong>Access Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
    </div>
    
    <p><a href="/">Back to Home</a></p>
   </body>
   </html>
   ```
6. Memberi Hak Akses dan Menjalankan Layanan
      ```bash
      chown -R www-data:www-data /var/www/app
      nginx -t
      service nginx restart
      service php8.4-fpm restart

      ```

