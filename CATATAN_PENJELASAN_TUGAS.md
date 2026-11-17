# Catatan & Dokumentasi Lengkap Proyek: Aplikasi Manajemen Data UMKM
**Mata Kuliah:** Pemrograman Mobile  
**Topik:** REST API & JSON Parsing (CodeIgniter 4 + Flutter HTTP & GetX + MySQL XAMPP)

---

## 1. Pendahuluan & Konsep Utama

Aplikasi ini dibangun menggunakan arsitektur **Client-Server terpisah (Decoupled Architecture)** dalam satu repository (*monorepo*):
1. **Backend:** CodeIgniter 4 sebagai penyedia layanan REST API yang berinteraksi langsung dengan basis data MySQL.
2. **Frontend:** Flutter sebagai aplikasi antarmuka pengguna (*client*) yang mengonsumsi REST API melalui protokol HTTP dan mengelola status antarmuka secara reaktif menggunakan **GetX**.

### Alur Pertukaran Data (REST API & JSON):
- **Request:** Client Flutter mengirimkan HTTP request (`GET`, `POST`, `PUT`, `DELETE`) ke server CI4 dengan format JSON atau Form Data.
- **Processing:** Server CI4 memproses rute, memvalidasi data request, menjalankan query database melalui Model, dan membungkus hasil dalam format standar JSON.
- **Parsing (fromJson):** Flutter menerima respon teks JSON mentah, mengubahnya menjadi `Map<String, dynamic>` via `jsonDecode()`, lalu memetakannya menjadi objek Dart bertipe kuat (*type-safe*) menggunakan factory constructor `Umkm.fromJson()`.
- **Reactivity (GetX):** State controller berupa `RxList<Umkm>` secara otomatis memperbarui widget tampilan (`Obx`) tanpa memerlukan reload manual.

---

## 2. Struktur Proyek & Direktori

```
tugasAPI/
│
├── ci4apiumkm/                          # BACKEND: CodeIgniter 4
│   ├── app/
│   │   ├── Config/
│   │   │   ├── Routes.php               # Pendaftaran endpoint /api/umkm
│   │   │   └── Filters.php              # Registrasi filter CORS global
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       └── UmkmController.php   # ResourceController CRUD UMKM
│   │   ├── Database/
│   │   │   └── Migrations/
│   │   │       └── ..._CreateUmkmTable.php # Skema tabel database `umkm`
│   │   ├── Filters/
│   │   │   └── Cors.php                 # Middleware penanganan CORS & preflight OPTIONS
│   │   └── Models/
│   │       └── UmkmModel.php            # Active Record Model CI4
│   └── .env                             # Pengaturan DB MySQL XAMPP (db_umkm)
│
├── umkm_api/                            # FRONTEND: Flutter
│   ├── lib/
│   │   ├── main.dart                    # Entry point GetMaterialApp & tema
│   │   ├── app/
│   │   │   ├── models/
│   │   │   │   └── umkm_model.dart      # Model Class (fromJson & toJson)
│   │   │   ├── services/
│   │   │   │   └── umkm_service.dart    # HTTP Client CRUD (GET, POST, PUT, DELETE)
│   │   │   ├── controllers/
│   │   │   │   └── umkm_controller.dart # GetxController (Reactive State & Logic)
│   │   │   └── views/
│   │   │       ├── umkm_view.dart       # Tampilan List UMKM (Read, Delete, Pull-to-Refresh)
│   │   │       └── umkm_form_page.dart  # Form Input Dinamis (Create & Edit UMKM)
│   │   └── routes/
│   │       └── app_pages.dart           # Rute halaman GetX
│   ├── test/
│   │   ├── umkm_crud_test.dart          # Unit test parsing & Live E2E test REST API
│   │   └── widget_test.dart             # UI widget test Form Tambah & Edit
│   └── pubspec.yaml                     # Dependencies: http & get
│
└── CATATAN_PENJELASAN_TUGAS.md          # Dokumen panduan ini
```

---

## 3. Implementasi Backend (CodeIgniter 4 & MySQL)

### A. Skema Basis Data
Database: `db_umkm`  
Tabel: `umkm`

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `id` | `INT(11) UNSIGNED` | Primary Key, Auto Increment |
| `nama_umkm` | `VARCHAR(100)` | Wajib diisi, Unik |
| `pemilik` | `VARCHAR(100)` | Nullable |
| `alamat` | `TEXT` | Nullable |
| `kategori` | `VARCHAR(50)` | Nullable (Kuliner, Fashion, dll) |
| `kontak` | `VARCHAR(20)` | Nullable (Nomor telepon/WA) |
| `created_at` | `DATETIME` | Waktu data dibuat |
| `updated_at` | `DATETIME` | Waktu data terakhir diperbarui |

Perintah pembuatan migrasi:
```bash
php spark make:migration CreateUmkmTable
php spark migrate
```

### B. UmkmModel (`app/Models/UmkmModel.php`)
- Mengaktifkan `$useTimestamps = true` agar `created_at` dan `updated_at` terisi otomatis oleh framework saat insert dan update.
- `$allowedFields` mengamankan database dari serangan mass assignment.

### C. UmkmController (`app/Controllers/Api/UmkmController.php`)
Mewarisi `CodeIgniter\RESTful\ResourceController` dengan format `json`:
1. `index()`: Mengambil seluruh daftar UMKM diurutkan dari ID terbesar (`DESC`).
2. `show($id)`: Mengambil detail satu data UMKM.
3. `create()`: 
   - Memvalidasi `nama_umkm` wajib diisi, minimal 3 karakter, dan belum pernah terdaftar (`is_unique[umkm.nama_umkm]`).
   - Mendukung request body berformat JSON maupun Form Data (`x-www-form-urlencoded`).
4. `update($id)`:
   - Memperbarui data UMKM yang sudah ada.
   - Mengatasi kendala validasi unik saat update: `is_unique[umkm.nama_umkm,id,{$id}]` agar tidak menolak pembaruan data jika nama tidak diubah.
5. `delete($id)`: Menghapus data UMKM dari basis data jika ID ditemukan, atau merespons `404 Not Found` jika data tidak ada.

### D. CORS Filter (`app/Filters/Cors.php`)
Menyediakan header standar keamanan HTTP:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE, PATCH`
- Menangani request preflight `OPTIONS` dari browser (Flutter Web) dan langsung merespons status `200 OK` sebelum rute utama dieksekusi.

---

## 4. Spesifikasi Endpoint REST API

| Method | Endpoint | Fungsi | Status Berhasil | Contoh Response JSON |
|---|---|---|---|---|
| **GET** | `/api/umkm` | Mengambil seluruh UMKM | `200 OK` | `{"success": true, "message": "...", "data": [...]}` |
| **GET** | `/api/umkm/{id}` | Mengambil detail 1 UMKM | `200 OK` | `{"success": true, "message": "...", "data": {...}}` |
| **POST** | `/api/umkm` | Menambah UMKM baru | `201 Created` | `{"success": true, "message": "Data UMKM berhasil ditambahkan", "data": {...}}` |
| **PUT** | `/api/umkm/{id}` | Mengedit UMKM | `200 OK` | `{"success": true, "message": "Data UMKM berhasil diperbarui", "data": {...}}` |
| **DELETE** | `/api/umkm/{id}` | Menghapus UMKM | `200 OK` | `{"success": true, "message": "Data UMKM berhasil dihapus", "data": {...}}` |

Jika terjadi kesalahan input atau data tidak ditemukan:
- **400 Bad Request:** `{"success": false, "message": "Validasi gagal", "errors": {...}}`
- **404 Not Found:** `{"success": false, "message": "Data UMKM tidak ditemukan"}`

---

## 5. Implementasi Frontend (Flutter + GetX)

### A. Model Class (`lib/app/models/umkm_model.dart`)
- **Factory `fromJson`:** Menerima `Map<String, dynamic>` dari hasil decoding JSON server dan mengubahnya menjadi objek Dart `Umkm`. Menggunakan `int.tryParse()` agar ID tetap valid meski server mengirimkan format angka maupun string.
- **Method `toJson`:** Mengubah objek `Umkm` kembali menjadi `Map<String, dynamic>` saat perlu dikirimkan ke server.

### B. Network Service (`lib/app/services/umkm_service.dart`)
- Terisolasi dari tampilan UI untuk menjaga prinsip *Separation of Concerns*.
- Memiliki deteksi IP platform otomatis:
  - Chrome / Windows Desktop / Web: `http://localhost:8080/api/`
  - Android Emulator: `http://10.0.2.2:8080/api/`
- Mengimplementasikan seluruh panggilan `http.get`, `http.post`, `http.put`, dan `http.delete` dengan parsing status code serta ekstraksi pesan error server secara rapi.

### C. GetX Controller (`lib/app/controllers/umkm_controller.dart`)
- Menyimpan status reaktif:
  - `umkmList`: Daftar entitas UMKM (`RxList<Umkm>`).
  - `isLoading`: Indikator loading saat memuat atau menghapus data (`RxBool`).
  - `isSaving`: Indikator loading saat tombol simpan pada form ditekan (`RxBool`).
  - `responseMessage`: Pesan status terkini dari server (`RxString`).
- Mengatur alur UI: Menampilkan notifikasi `Get.snackbar` (warna hijau untuk berhasil, merah untuk error validasi/koneksi), melakukan navigasi kembali (`Get.back()`), serta melakukan *auto-refresh* data setelah create, update, atau delete.

### D. Views & Antarmuka Pengguna
1. **`UmkmView` (`lib/app/views/umkm_view.dart`):**
   - Menggunakan `Obx` untuk me-render ulang UI saat `umkmList` atau `isLoading` berubah.
   - Dilengkapi `RefreshIndicator` untuk fitur *pull-to-refresh*.
   - Setiap kartu UMKM menampilkan ID, Nama UMKM, Kategori, Pemilik, Alamat, dan Kontak.
   - Tombol **Edit** (ikon pensil) untuk membuka form edit data.
   - Tombol **Hapus** (ikon tempat sampah merah) dengan dialog konfirmasi (`Get.defaultDialog`) untuk mencegah penghapusan tidak sengaja.
   - `FloatingActionButton` untuk navigasi ke form penambahan UMKM baru.

2. **`UmkmFormPage` (`lib/app/views/umkm_form_page.dart`):**
   - Mendukung dua mode: **Tambah Baru** dan **Edit Data**.
   - Jika menerima parameter `umkm`, seluruh `TextEditingController` akan terisi otomatis dengan data lama.
   - Dilengkapi validasi form (`_formKey.currentState!.validate()`).
   - Tombol simpan menampilkan indikator loading saat proses penyimpanan sedang berlangsung.

---

## 6. Cara Menjalankan Aplikasi

### Langkah 1: Pastikan MySQL XAMPP Aktif
1. Buka **XAMPP Control Panel**.
2. Klik tombol **Start** pada modul **MySQL** (pastikan port 3306 aktif).

### Langkah 2: Jalankan Server Backend CodeIgniter 4
Buka terminal di folder `ci4apiumkm`:
```bash
cd D:\CPP\Belajar\PemrogramanMobile\tugasAPI\ci4apiumkm
php spark serve --port 8080 --host 0.0.0.0
```
Server REST API akan berjalan di `http://localhost:8080/api/umkm`.

### Langkah 3: Jalankan Aplikasi Frontend Flutter
Buka terminal baru di folder `umkm_api`:
```bash
cd D:\CPP\Belajar\PemrogramanMobile\tugasAPI\umkm_api

# Untuk menjalankan di Google Chrome (Web):
flutter run -d chrome

# ATAU untuk menjalankan di Windows Desktop:
flutter run -d windows

# ATAU jika menggunakan Android Emulator:
flutter run
```

---

## 7. Hasil Pengujian Nyata (Real Verification Test)

Pengujian telah dilakukan secara langsung terhadap REST API CI4 yang berjalan dan basis data MySQL nyata:

1. **Uji Endpoint REST API (HTTP Request):**
   - `GET /api/umkm`: Status 200 OK, mengembalikan array data UMKM.
   - `POST /api/umkm`: Status 201 Created, data tersimpan di tabel `umkm` MySQL.
   - `PUT /api/umkm/{id}`: Status 200 OK, data berhasil diperbarui tanpa terbentur validasi duplikat.
   - `DELETE /api/umkm/{id}`: Status 200 OK, data terhapus dari MySQL.
   - `POST /api/umkm (validasi gagal)`: Status 400 Bad Request, pesan error divalidasi dengan baik.

2. **Uji Otomatis Flutter (`flutter test`):**
   - Unit test parsing `Umkm.fromJson` & `toJson`: **PASSED**.
   - Live E2E REST API tests (GET, POST, PUT, DELETE via `UmkmService`): **PASSED**.
   - UI Widget tests (Form rendering & auto-fill edit mode): **PASSED**.
   - Hasil akhir: **`7 passed, 0 failed`**.
