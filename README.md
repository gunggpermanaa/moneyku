# MoneyKu : Catatan Keuanganmu Sehari-hari

MoneyKu adalah aplikasi pencatatan keuangan pribadi yang membantu pengguna mengelola pemasukan dan pengeluaran harian secara praktis, terstruktur, dan informatif. Aplikasi ini dirancang untuk meningkatkan kesadaran finansial pengguna melalui pencatatan rutin dan visualisasi data keuangan.

---

## 👥 Our Team

<p align="center">
  <img src="https://github.com/user-attachments/assets/2e993515-c397-45f3-97ae-46d44b74c417" width="130"/>
  <img src="https://github.com/user-attachments/assets/19cc2d7a-d90b-4c2c-9b4a-cfa64a75357e" width="130"/>
  <img src="https://github.com/user-attachments/assets/3ac8f8d2-e299-49fd-80db-405c492a29f9" width="130"/>
  <img src="https://github.com/user-attachments/assets/4f2a7b2e-ddea-4563-a45f-18b39bb76646" width="130"/>
  <img src="https://github.com/user-attachments/assets/REPLACE_WITH_LAST_IMAGE" width="130"/>
</p>

<p align="center">
  <a href="https://informatika.uinsgd.ac.id" target="_blank">
    Teknik Informatika
  </a>
  &nbsp;•&nbsp;
  <a href="https://uinsgd.ac.id" target="_blank">
    UIN Sunan Gunung Djati Bandung
  </a>
</p>

---

## 📌 Latar Belakang Masalah

Pengelolaan keuangan pribadi merupakan aspek penting dalam kehidupan sehari-hari. Keuangan yang terkelola dengan baik dapat membantu seseorang memenuhi kebutuhan hidup, merencanakan masa depan, serta menghindari masalah finansial seperti utang berlebih dan ketidakstabilan ekonomi. Namun pada kenyataannya, masih banyak individu yang belum memiliki kesadaran dan kebiasaan dalam mencatat serta mengelola keuangan mereka secara teratur.

Di era digital saat ini, aktivitas keuangan menjadi semakin kompleks. Pengeluaran harian seperti makan, transportasi, hiburan, hingga langganan digital sering kali tidak disadari jumlah totalnya. Banyak orang hanya berfokus pada pemasukan tanpa memahami ke mana uang mereka digunakan. Hal ini menyebabkan sulitnya mengontrol pengeluaran, tidak tercapainya target tabungan, dan munculnya tekanan finansial.

Kondisi tersebut diperparah dengan kurangnya alat bantu yang mudah digunakan, sederhana, dan sesuai dengan kebutuhan pengguna sehari-hari. Oleh karena itu, dibutuhkan sebuah aplikasi yang dapat membantu pengguna dalam mencatat pemasukan dan pengeluaran secara praktis, menampilkan ringkasan keuangan, serta memberikan gambaran kondisi finansial secara jelas. **MoneyKu** hadir sebagai solusi digital untuk membantu pengguna mengelola dan mencatat keuangan harian secara efektif dan efisien.

---

## ❗ Identifikasi Masalah

Permasalahan utama yang melatarbelakangi pengembangan aplikasi MoneyKu antara lain:

- Tidak terbiasanya pengguna mencatat pemasukan dan pengeluaran harian
- Sulitnya memantau kondisi keuangan karena tidak adanya ringkasan visual
- Pengeluaran sering kali lebih besar dari pemasukan tanpa disadari
- Kurangnya kesadaran dalam perencanaan keuangan jangka pendek dan panjang
- Belum tersedianya aplikasi pencatatan keuangan yang sederhana dan mudah digunakan

---

## 🛠️ Metode Pendekatan

Pengembangan aplikasi MoneyKu menggunakan metodologi **CRISP-DM (Cross Industry Standard Process for Data Mining)** untuk memahami kebutuhan pengguna serta mengolah data keuangan secara sistematis.

Tahapan CRISP-DM yang diterapkan meliputi:

1. **Business Understanding** – Memahami permasalahan pengelolaan keuangan  
2. **Data Understanding** – Memahami karakteristik data keuangan pengguna  
3. **Data Preparation** – Menyiapkan dan membersihkan data  
4. **Modeling** – Membangun model analisis dan pola pengeluaran  
5. **Evaluation** – Mengevaluasi hasil analisis  
6. **Deployment** – Implementasi hasil analisis ke dalam dashboard aplikasi  

---

## 🎯 Tujuan & Kriteria Kesuksesan

Tujuan utama pengembangan aplikasi MoneyKu adalah:

- Mengetahui pola pemasukan dan pengeluaran harian pengguna
- Menyajikan ringkasan keuangan dalam bentuk grafik dan statistik
- Membantu pengguna mengontrol dan mengevaluasi pengeluaran
- Meningkatkan kesadaran terhadap pengelolaan keuangan pribadi
- Menyediakan aplikasi pencatatan keuangan yang mudah dan informatif

Keberhasilan aplikasi diukur dari kemudahan penggunaan, keakuratan data, serta kemampuan aplikasi dalam membantu pengguna memahami kondisi keuangannya.

---

## ⏱️ Timeline Mini Riset

Pengembangan aplikasi MoneyKu mengikuti tahapan berikut:

- Penentuan topik penelitian dan aplikasi  
- Pengumpulan dataset keuangan pengguna  
- Pemilihan metode analisis dan visualisasi  
- Business Understanding  
- Data Understanding  
- Data Preparation  
- Modeling  
- Evaluation  
- Deployment Dashboard Aplikasi  

---

## 📊 Data Understanding

### Kebutuhan Data
- Data pemasukan pengguna  
- Data pengeluaran pengguna  
- Kategori transaksi  
- Waktu dan tanggal transaksi  
- Catatan tambahan (opsional)  

### Pengambilan Data
Data diperoleh langsung dari input pengguna melalui aplikasi MoneyKu dan bersifat personal serta real-time.

### Integrasi Data
Data berasal dari satu sumber utama dan diintegrasikan antar transaksi, kategori, dan pengguna untuk menghasilkan laporan keuangan.

### Karakteristik Data
- **Tanggal Transaksi** (Date)  
- **Jumlah Uang** (Integer)  
- **Jenis Transaksi** (Pemasukan / Pengeluaran)  
- **Kategori** (String)  
- **Catatan** (String)  
- **User ID** (Integer)  

### Validasi Data
- Nominal transaksi tidak bernilai negatif  
- Tanggal transaksi valid  
- Kategori sesuai pilihan  
- Data tersimpan dengan aman dan konsisten  

---

## 🧹 Data Preparation

Tahapan persiapan data meliputi:
- Pembersihan data duplikat  
- Pengelompokan transaksi berdasarkan kategori  
- Penyaringan data berdasarkan periode waktu  
- Penyesuaian format untuk visualisasi  

---

## 📈 Data Visualization

Dashboard MoneyKu menampilkan:
- Statistik pemasukan dan pengeluaran harian  
- Grafik perbandingan pemasukan dan pengeluaran  
- Diagram kategori pengeluaran terbesar  
- Statistik berdasarkan periode waktu  
- Ringkasan kondisi keuangan pengguna  

---

## 🤖 Modeling

Model analisis digunakan untuk mengidentifikasi pola pengeluaran pengguna dan dapat dikembangkan lebih lanjut untuk memberikan rekomendasi pengelolaan keuangan.

---

## 🧪 Evaluation

Evaluasi dilakukan berdasarkan kesesuaian hasil analisis dengan kondisi keuangan pengguna serta kemudahan dalam memahami informasi yang disajikan.

---

## 📊 Dashboard

Dashboard **MoneyKu: Catatan Keuanganmu Sehari-hari** menyajikan informasi keuangan secara visual, ringkas, dan mudah dipahami untuk mendukung pengambilan keputusan finansial.

---

## 👨‍💻 Pengembang

- AGUNG PERMANA ( 1237050093 )
- ARIEL AZIZ BHADRIKA ( 1237050108 )
- ANDHIKA PRATAMA KURNIAWAN ( 1237050117 )
- FAUZI RIZKI HERMAWAN ( 1237050115 )

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan pembelajaran dan pengembangan aplikasi.  
Silakan digunakan dan dikembangkan kembali sesuai kebutuhan.
