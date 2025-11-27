# PingChekker 📡

PingChekker adalah utilitas native macOS yang digunakan untuk memonitor kualitas koneksi internet secara realtime. Berbeda dengan perintah ping biasa di terminal, PingChekker menerjemahkan data latensi mentah menjadi status yang mudah dipahami (misalnya: "Elite", "Bagus", "Lag") dan menampilkan stabilitas jaringan melalui antarmuka bergaya widget yang ringkas.

<p align="center">
<img src="https://github.com/user-attachments/assets/350d5552-a218-416d-9d36-733f928f549f" width="600"/>
</p>

## 🚀 Fitur Utama

- Monitoring Realtime: Menampilkan latensi (ms) menggunakan speedometer dinamis.
- Analisis Stabilitas: Menghitung Jitter dan Packet Loss untuk mengetahui kualitas jaringan yang sebenarnya.
- Rata-Rata Sesi: Memberikan skor kualitas berdasarkan keseluruhan durasi sesi pemantauan.
- Feedback Manusiawi: Pesan seperti "Sangat cocok untuk gaming", "Bagus untuk streaming".
- Desain Native: SwiftUI + NSVisualEffectView.
- Menu Bar Support: (Segera hadir)

## 🛠 Cara Kerja

PingChekker bekerja menggunakan mekanisme mikro dan makro untuk menghasilkan data yang stabil dan akurat.

### Mekanisme Mikro
Menggunakan SimplePing untuk mengirim ICMP packet ke 8.8.8.8 tiap 1 detik, lalu mengukur latency.

### Mekanisme Makro (Buffer 10 detik)
- Mengumpulkan sampel ping (default 10)
- Menghitung:
  - Rata-rata Latency
  - Jitter (incremental)
  - Packet Loss
- Session Average diperbarui tiap 1 menit

## 📏 Definisi & Cara Perhitungan

### Latency (ms)
Waktu pulang–pergi paket (RTT).

Rumus:
```
latency = (receivedTime - sendTime) * 1000
```
Kode:
```swift
let latency = Date().timeIntervalSince(sendDate) * 1000
```

### Jitter (ms)
Variasi antar ping.

Rumus sederhana:
```
jitter = rata-rata(|latency[i] - latency[i-1]|)
```
Kode incremental:
```swift
if let prev = previousLatency {
    jitterSum += abs(latency - prev)
}
```

### Packet Loss (%)
Persentase paket yang tidak dibalas.
```
loss = ((sent - received) / sent) * 100
```

### Session Average (ms)
Rata-rata latency jangka panjang (update tiap 1 menit).

```
cachedSessionAvg = totalSessionLatency / totalSessionCount
```

## 🧠 Arsitektur

Mengikuti MVVM:
- Core/
- Features/InternetMonitor/
- App/

## 💻 Teknologi
- Swift
- SwiftUI
- CFNetwork + SimplePing
- macOS 12+

## 📦 Instalasi
```
git clone https://github.com/yourusername/PingChekker.git
open PingChekker.xcodeproj
```

Aktifkan:
- App Sandbox
- Outgoing Connections

Jalankan:
```
Cmd + R
```

## 📝 Lisensi
MIT License.
