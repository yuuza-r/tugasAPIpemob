# Refleksi Pembelajaran: Implementasi REST API & JSON Parsing
**Mata Kuliah:** Pemrograman Mobile  
**Topik:** REST API dengan CodeIgniter 4, MySQL, dan Flutter (GetX & HTTP)  
**Tanggal:** 17 November 2026  
**Penulis:** Muhammad Rifqi Alfa Reza  

---

## 1. Ringkasan Pembelajaran Hari Ini
Hari ini saya mempelajari dan mengimplementasikan secara langsung integrasi menyeluruh (*full-stack*) antara aplikasi mobile **Flutter** sebagai *client* dan framework **CodeIgniter 4 (CI4)** sebagai *server REST API* dengan basis data **MySQL**.

Aplikasi yang dibangun adalah **Sistem Manajemen Data UMKM**, yang mencakup siklus hidup data lengkap (**CRUD**: *Create, Read, Update, Delete*).

---

## 2. Poin-Poin Kunci Konseptual yang Dipahami

### A. Arsitektur Client-Server & Protokol REST
- **Statelessness:** Setiap HTTP request yang dikirimkan oleh Flutter bersifat independen; server tidak menyimpan sesi client. Seluruh konteks dikirimkan melalui payload dan parameter URL.
- **Semantika HTTP Method:**
  - `GET` untuk mengambil data tanpa mengubah keadaan server (*idempotent & safe*).
  - `POST` untuk membuat data entitas baru.
  - `PUT` untuk memperbarui data yang sudah ada berdasarkan identifikasi unik (`id`).
  - `DELETE` untuk menghapus entitas data dari basis data.
- **Standardisasi Respon JSON:** Struktur respon API yang konsisten (`success`, `message`, `data`, dan `errors`) mempermudah client dalam melakukan validasi status dan parsing data secara seragam.

### B. Serialisasi & Deserialisasi JSON di Flutter
- **Manual Parsing vs Model Class Parsing:** Manual parsing menggunakan `Map['key']` sangat rentan terhadap *human error* dan *runtime type mismatch*. Dengan menggunakan pola **Model Class** (`fromJson` dan `toJson`), data menjadi *type-safe* dan terstruktur.
- **Null Safety & Type Casting:** Penggunaan `int.tryParse(json['id'].toString())` dan fallback operator (`??`) sangat krusial untuk mencegah *app crash* ketika tipe data dari API berubah (misal: integer dikembalikan sebagai string oleh driver MySQL/PHP).

### C. State Management & Reaktivitas Menggunakan GetX
- Memisahkan kode menjadi 4 lapisan yang bersih (*Separation of Concerns*):
  1. **Model:** Representasi data entitas UMKM.
  2. **Service:** Lapisan murni komunikasi jaringan (*network request*).
  3. **Controller:** Otak aplikasi yang memegang status reaktif (`.obs`, `RxList`, `RxBool`) dan logika bisnis.
  4. **View:** Antarmuka visual yang bereaksi secara otomatis (`Obx`) setiap kali ada perubahan pada state tanpa perlu pemanggilan manual `setState()`.
- Pengalaman pengguna yang baik dibangun dengan menyediakan **Loading State**, **Pull-to-Refresh**, dialog konfirmasi sebelum penghapusan data, dan notifikasi visual (*Snackbar*) untuk setiap aksi.

---

## 3. Kendala Nyata & Solusi Teknis (Technical Problem Solving)

Dalam praktik hari ini, ada beberapa kendala teknis penting yang berhasil dianalisis dan diselesaikan:

1. **CORS (Cross-Origin Resource Sharing) & Preflight `OPTIONS`:**
   - *Masalah:* Ketika aplikasi Flutter dijalankan di web browser, browser menerapkan *Same-Origin Policy* dan mengirimkan request preflight `OPTIONS` sebelum request `POST`/`PUT`/`DELETE`.
   - *Solusi:* Dibuat middleware filter `App\Filters\Cors` yang menyetel header `Access-Control-Allow-Origin: *` dan langsung merespons request `OPTIONS` dengan status `200 OK` sebelum rute controller dieksekusi.

2. **Perbedaan Parsing Payload pada HTTP PUT di CodeIgniter 4:**
   - *Masalah:* PHP secara default tidak mengisi variabel `$_POST` ketika request dikirimkan dengan metode `PUT`. Selain itu, memanggil `$this->request->getJSON()` pada request yang bukan JSON murni dapat memicu *HTTPException*.
   - *Solusi:* Controller dimodifikasi dengan blok pengaman (*safe fallback*) yang memeriksa JSON terlebih dahulu dengan `try-catch`, lalu membaca data melalui `$this->request->getRawInput()` atau `$this->request->getPost()`.

3. **Validasi Unik (`is_unique`) saat Operasi Update:**
   - *Masalah:* Pada saat mengedit UMKM tanpa mengubah nama, validasi `is_unique[umkm.nama_umkm]` menolak update karena menganggap nama tersebut sudah ada di database.
   - *Solusi:* Menambahkan pengecualian ID saat update: `is_unique[umkm.nama_umkm,id,{$id}]`.

4. **Multiplatform Base URL:**
   - *Masalah:* `localhost` pada Android Emulator merujuk ke perangkat emulator itu sendiri, bukan komputer host tempat server CI4 berjalan.
   - *Solusi:* Menambahkan getter `defaultBaseUrl` dinamis di Flutter yang otomatis memakai `10.0.2.2:8080` jika berjalan di Android dan `localhost:8080` jika di Web/Desktop.

---

## 4. Evaluasi & Pengujian

Pembelajaran hari ini menekankan pentingnya pengujian nyata (*real testing*):
- Pengujian endpoint API dilakukan secara langsung terhadap basis data MySQL aktif menggunakan HTTP client.
- Pengujian otomatis (*automated test suite*) pada Flutter melalui `flutter test` mencakup pengujian unit model parsing, pengujian integrasi *end-to-end* (E2E) ke server REST API, dan pengujian rendering UI widget. Semua 7 pengujian berhasil dilewati (**100% Passed**).

---

## 5. Kesimpulan Pribadi
Melalui modul ini, saya tidak hanya memahami sintaks kode, tetapi juga memahami gambaran besar bagaimana industri teknologi membangun aplikasi modern: memisahkan backend yang kuat dan aman dengan frontend yang responsif dan reaktif. Kemampuan melakukan *debugging* secara logis ketika terjadi kendala jaringan atau format data adalah nilai paling berharga yang saya dapatkan hari ini.
