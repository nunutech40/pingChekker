<img width="290" height="1166" alt="FlowChart - Get PacketLoss" src="https://github.com/user-attachments/assets/e20f54f4-e415-4e4d-afea-4f602eb1a6a3" /># PingChekker 📡

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

## Flow Use Simple Ping to Send Ping and Get return as ms.
<img width="424" height="1022" alt="Use Ping Simple Work Flow" src="https://github.com/user-attachments/assets/7803d996-85f6-4e57-afa1-ca7a0c355e35" />


### Latency (ms)
Waktu pulang–pergi paket (RTT).
<img width="462" height="1359" alt="Get Latency - RealTime" src="https://github.com/user-attachments/assets/fdae4fa9-a6d7-4c23-9a11-86c7bc612200" />

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
<img width="1057" height="913" alt="FlowChart - Get Jitter" src="https://github.com/user-attachments/assets/82313bb0-e93a-4cc2-aebb-349c31756124" />

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
<img width="290" height="1166" alt="FlowChart - Get PacketLoss" src="https://github.com/user-attachments/assets/1cdfb8f2-7dd3-458d-8ae0-837338f10f93" />

```
loss = ((sent - received) / sent) * 100
```

### Session Average (ms)
Rata-rata latency jangka panjang (update tiap 1 menit).

```
cachedSessionAvg = totalSessionLatency / totalSessionCount
```
### Hitung MOS (%)
MOS adalah skor kualitas koneksi 1.0–5.0 berdasarkan standar **ITU-T G.107 (E-Model)**.
PingChekker menghitung MOS menggunakan tiga parameter utama: **latency**, **jitter**, dan **packet loss**.
<img width="1225" height="2386" alt="GET MOS - FLOW" src="https://github.com/user-attachments/assets/0153f646-509e-4cef-9c11-5bb3e8073805" />


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

## Flow Chart Fitur
https://app.diagrams.net/#DDiagram%20Tanpa%20Judul.drawio#%7B%22pageId%22%3A%22Gh7RQAuNiNxMG_v7OheC%22%7D

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
