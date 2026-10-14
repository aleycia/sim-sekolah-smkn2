# Sistem Informasi Sekolah — SMK Negeri 2 Surakarta

Website demo untuk proyek pembelajaran PPLG. Frontend menggunakan HTML, CSS, JavaScript dan Supabase untuk autentikasi serta database PostgreSQL.

## Fitur
- Registrasi, login, dan logout dengan Supabase Auth.
- Role `admin`, `guru`, dan `siswa` pada profil.
- Dashboard dengan ringkasan jumlah siswa, guru, jadwal, dan pengumuman.
- CRUD data siswa, guru, jadwal pelajaran, nilai, presensi, dan pengumuman (khusus admin).
- Pencarian data, tampilan responsif, dan profil sekolah.
- Row Level Security (RLS) untuk melindungi operasi database.

## 1. Siapkan Supabase
1. Buka https://supabase.com/ lalu buat project baru.
2. Masuk ke **SQL Editor** pada project.
3. Buka file `supabase-schema.sql`, salin seluruh isinya, lalu jalankan (**Run**) di SQL Editor.
4. Buka **Project Settings → API** (atau bagian Data API sesuai tampilan dashboard).
5. Salin **Project URL** dan **anon/public key**. Jangan gunakan `service_role` key di frontend.

## 2. Hubungkan website ke Supabase
1. Buka `app.js` dengan editor teks.
2. Cari dua baris berikut di bagian paling atas:
   ```js
   const SUPABASE_URL = "GANTI_DENGAN_SUPABASE_PROJECT_URL";
   const SUPABASE_ANON_KEY = "GANTI_DENGAN_SUPABASE_ANON_KEY";
   ```
3. Ganti teks di dalam tanda kutip dengan Project URL dan anon/public key milik project Supabase.
4. Simpan file.

## 3. Jalankan di komputer
Cara paling mudah:
1. Ekstrak ZIP.
2. Buka folder `sim-sekolah-smkn2-surakarta`.
3. Jalankan server lokal. Jika Python tersedia, buka terminal di folder itu lalu jalankan:
   ```bash
   python -m http.server 5500
   ```
4. Buka `http://localhost:5500` di browser.
   Alternatif: gunakan ekstensi **Live Server** di Visual Studio Code. Sebaiknya jangan membuka `index.html` langsung dengan `file://`.

## 4. Buat akun admin pertama
1. Daftarkan akun melalui halaman website.
2. Jika Supabase meminta konfirmasi email, buka email dan konfirmasi terlebih dahulu. Untuk demo kelas, pengaturan konfirmasi email dapat disesuaikan di Authentication → Providers → Email pada project Supabase.
3. Buka Supabase → SQL Editor.
4. Jalankan perintah berikut dengan mengganti email contoh:
   ```sql
   update public.profiles
   set role = 'admin'
   where id = (
     select id from auth.users where email = 'email-admin-anda@example.com'
   );
   ```
5. Keluar lalu masuk lagi agar peran admin termuat. Akun admin kini dapat menambah, mengedit, dan menghapus data.

## 5. Deploy ke Vercel
1. Unggah folder project ke repository GitHub (isi folder ini, bukan ZIP-nya).
2. Di Vercel pilih **Add New → Project**, lalu impor repository.
3. Karena ini website statis, Framework Preset pilih **Other**. Build Command dan Output Directory bisa dikosongkan jika Vercel mendeteksi static files; bila diminta, gunakan Output Directory `.`.
4. Deploy. Setelah berhasil, buka URL yang diberikan Vercel.
5. Jika memakai Supabase Auth dengan konfirmasi email, tambahkan domain website ke Authentication → URL Configuration → Redirect URLs bila diperlukan.

## Struktur file
- `index.html` — struktur halaman dan form autentikasi.
- `style.css` — desain responsif.
- `app.js` — logika login, navigasi, dan CRUD.
- `supabase-schema.sql` — tabel, trigger, dan kebijakan RLS.
- `README.md` — panduan setup.

## Catatan keamanan dan batasan
- Project ini merupakan starter/demo pembelajaran, bukan sistem resmi yang siap menangani data siswa sungguhan.
- Semua tabel akademik pada contoh ini dapat dibaca oleh pengguna yang sudah login; hanya admin dapat mengubahnya. Sebelum digunakan sungguhan, batasi akses guru/siswa per kelas atau pemilik data, tambahkan audit log, backup, validasi, dan pengujian keamanan.
- Jangan memasukkan data pribadi siswa sungguhan ke demo publik.
- Jangan pernah menaruh Supabase `service_role` key di file frontend.
- Detail sekolah, alamat, kontak, program keahlian, dan kalender harus diverifikasi sebelum dipublikasikan.
