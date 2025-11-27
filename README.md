PingChekker 📡

PingChekker adalah utilitas native macOS yang digunakan untuk memonitor kualitas koneksi internet secara realtime. Berbeda dengan perintah ping biasa di terminal, PingChekker menerjemahkan data latensi mentah menjadi status yang mudah dipahami (misalnya: "Elite", "Bagus", "Lag") dan menampilkan stabilitas jaringan melalui antarmuka bergaya widget yang ringkas.

<p align="center">
<img src="https://github.com/user-attachments/assets/350d5552-a218-416d-9d36-733f928f549f" alt="PingChekker Screenshot" width="600"/>
</p>

🚀 Fitur Utama

- Monitoring Realtime: Menampilkan latensi (ms) menggunakan speedometer dinamis.
- Analisis Stabilitas: Menghitung Jitter dan Packet Loss untuk mengetahui kualitas jaringan yang sebenarnya.
- Rata-Rata Sesi: Memberikan skor kualitas berdasarkan keseluruhan durasi sesi pemantauan.
- Feedback Manusiawi: Pesan kontekstual seperti "Sangat cocok untuk gaming", "Bagus untuk streaming".
- Desain Native: Dibangun dengan SwiftUI dan efek kaca (NSVisualEffectView) yang menyatu dengan tampilan macOS.
- Menu Bar Support: (Segera hadir)

🛠 Cara Kerja

PingChekker tidak sekadar melakukan ping. Aplikasi ini menggunakan logika buffering khusus agar data tetap akurat dan tampilan UI tetap stabil.

1. Mekanisme Inti (Proses Mikro)

Aplikasi menggunakan SimplePing dari Apple untuk menangani ICMP packet level rendah. Host (default: 8.8.8.8) akan di-resolve, paket dikirim, dan waktu respons diukur.

2. Mekanisme Bisnis (Proses Makro)

Untuk mencegah tampilan UI bergetar dan agar datanya lebih bermakna, PingChekker menggunakan sistem Sampling & Buffering:

- Sampling: Tidak setiap packet langsung ditampilkan, tetapi dikumpulkan di buffer (misalnya 10 sampel).
- Perhitungan: Setelah buffer penuh, aplikasi menghitung:
  - Rata-Rata Latensi
  - Jitter (perbedaan antar ping)
  - Packet Loss (persentase kegagalan ping)
- Reporting: Hasil yang sudah diolah dikirim ke ViewModel untuk memperbarui warna UI, teks, dan gauge.

🏗 Arsitektur

Proyek ini mengikuti pola MVVM (Model-View-ViewModel) dengan pembagian jelas antara Core dan Features.

<img width="715" height="304" alt="Screenshot 2025-11-27 at 16 08 17" src="https://github.com/user-attachments/assets/af13f4d5-75ee-4db0-87c0-6a634a7cba9d" />

💻 Teknologi

- Bahasa: Swift
- UI Framework: SwiftUI
- Networking: Foundation, CFNetwork (melalui SimplePing)
- Platform: macOS 12.0+

📦 Instalasi

Clone repository:

git clone https://github.com/yourusername/PingChekker.git

Buka PingChekker.xcodeproj dengan Xcode.

Pastikan App Sandbox aktif di "Signing & Capabilities" serta opsi "Outgoing Connections (Client)" dicentang.

Build & Run (Cmd + R).

📝 Lisensi

Proyek ini dirilis di bawah MIT License.
