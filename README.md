# PingChekker 📡

PingChekker adalah utilitas native macOS yang dirancang untuk memantau kualitas koneksi internet secara realtime dengan pendekatan yang visual dan mudah dipahami. Tidak hanya menampilkan angka ping mentah, aplikasi ini menerjemahkan data teknis menjadi wawasan yang dapat ditindaklanjuti untuk gamer, pekerja remote, dan streamer.

<p align="center">
  <img width="480" src="https://github.com/user-attachments/assets/476522fc-6483-447e-a2ae-7ea6bdbb0124" alt="PingChekker Dashboard" />
</p>

## 🎯 Tujuan Aplikasi
Aplikasi ini dibuat untuk menjawab pertanyaan sederhana: *"Kenapa internet saya terasa lambat?"*
PingChekker membantu pengguna untuk:
- Mengetahui **stabilitas** koneksi (bukan hanya kecepatan download).
- Mendeteksi **Jitter** (variasi ping) yang menyebabkan lag pada game online.
- Mengukur **MOS (Mean Opinion Score)** untuk memprediksi kualitas panggilan suara/video (Zoom, Google Meet).
- Memantau riwayat performa jaringan dari waktu ke waktu.

## 🚀 Cara Penggunaan
1. **Buka Aplikasi**: PingChekker akan otomatis memulai pemantauan ke server target (Default: Google DNS 8.8.8.8).
2. **Lihat Dashboard**:
   - **Speedometer**: Menunjukkan latensi realtime.
   - **Indikator Kualitas**: Status verbal seperti *ELITE*, *STABLE*, atau *LAGGY*.
   - **MOS Score**: Skor 1-5 yang menunjukkan kelayakan jaringan untuk VoIP/Gaming.
3. **Menu Bar**: Pantau status jaringan langsung dari menu bar macOS tanpa membuka jendela utama.
4. **Settings (Pengaturan)**:
   - **Network History**: Lihat log performa jaringan sebelumnya.
   - **WiFi Details**: Cek kekuatan sinyal (RSSI), channel, dan noise level.
   - **Custom Host**: Ubah target ping ke server pilihan Anda (misal: server game tertentu).

## ✨ Fitur Utama
### 1. Monitoring Realtime & Visualisasi
- **Smart Speedometer**: Visualisasi latensi dengan kode warna (Hijau = Bagus, Merah = Buruk).
- **Human-Readable Status**: Menerjemahkan angka teknis menjadi bahasa manusia (contoh: *"Perfect for Gaming"* atau *"Severe Disruption"*).

### 2. Analisis Kualitas Jaringan (QoS)
- **Jitter Detection**: Mendeteksi ketidakstabilan koneksi.
- **MOS Calculation**: Menghitung skor kualitas suara berdasarkan standar ITU-T G.107.
- **Packet Loss Tracker**: Memantau paket data yang hilang.

### 3. Utilitas Jaringan Lanjutan
- **Network History**: Menyimpan riwayat sesi secara otomatis menggunakan **Core Data**. Riwayat dikelompokkan berdasarkan nama jaringan (SSID) dan Host.
- **WiFi Analyzer**: Menampilkan detail teknis WiFi seperti BSSID, RSSI, Tx Rate, dan Security Protocol.

### 4. Integrasi macOS
- **Menu Bar App**: Ikon status dinamis di menu bar.
- **Native SwiftUI**: Tampilan modern, ringan, dan responsif.
- **Multi-Language**: Mendukung Bahasa Indonesia dan Inggris secara penuh.

## 🛠️ Teknologi yang Digunakan
Aplikasi ini dibangun menggunakan teknologi native Apple untuk performa maksimal:

- **Bahasa Pemrograman**: Swift 5.0
- **UI Framework**: SwiftUI (MVVM Architecture).
- **Networking**: 
  - **SimplePing**: Wrapper untuk ICMP ping level rendah.
  - **Network Framework**: Untuk pemantauan status koneksi global.
  - **CoreWLAN**: Untuk mengambil detail informasi WiFi (SSID, RSSI, Noise).
- **Data Persistence**: Core Data (Penyimpanan riwayat sesi).
- **Localization**: String Catalogs (.xcstrings) untuk dukungan multi-bahasa.

## 📐 Arsitektur & Cara Kerja
PingChekker menggunakan pola **MVVM (Model-View-ViewModel)** untuk memisahkan logika bisnis dari tampilan antarmuka.

### Mekanisme Ping
1. **Mikro (Detik)**: Mengirim paket ICMP setiap detik untuk mendapatkan latensi instan.
2. **Makro (Agregat)**: Mengumpulkan sampel setiap 10 detik untuk menghitung Jitter dan Packet Loss.
3. **Sesi**: Data dirata-rata setiap menit dan disimpan ke Core Data jika terjadi perubahan jaringan atau aplikasi ditutup.

<details>
<summary>Lihat Diagram Alur (Flowchart)</summary>

#### Flow MOS Calculation
<img src="https://github.com/user-attachments/assets/0153f646-509e-4cef-9c11-5bb3e8073805" alt="MOS Flow" width="600"/>

#### Flow Jitter Calculation
<img src="https://github.com/user-attachments/assets/82313bb0-e93a-4cc2-aebb-349c31756124" alt="Jitter Flow" width="600"/>

</details>

## 📦 Instalasi & Pengembangan

### Persyaratan Sistem
- macOS 12.0 (Monterey) atau lebih baru.
- Xcode 14.0+ (untuk pengembangan).

### Langkah Instalasi
1. Clone repositori ini:
   ```bash
   git clone https://github.com/yourusername/PingChekker.git
   ```
2. Buka project di Xcode:
   ```bash
   open PingChekker.xcodeproj
   ```
3. Pastikan **App Sandbox** dikonfigurasi untuk mengizinkan "Outgoing Connections (Client)".
4. Jalankan aplikasi (Cmd + R).

## 📝 Lisensi
PingChekker dilisensikan di bawah MIT License.

---
**Dibuat dengan ❤️ oleh Nunu Nugraha**
