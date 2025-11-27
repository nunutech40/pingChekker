//
//  PingService.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.

import Foundation

// =================================================================================
// MARK: - DOKUMENTASI PING SERVICE
// =================================================================================
//
// Service ini berfungsi sebagai "Jantung" pemantauan kualitas jaringan.
// Berbeda dengan ping biasa yang hanya melihat kecepatan (Latency),
// service ini menghitung KESTABILAN (Quality of Service) untuk menyimpulkan
// apakah sebuah tempat (Cafe/Kantor/Rumah) layak untuk aktivitas berat.
//
// --- KENAPA BUTUH JITTER? ---
// Latency rendah (misal 20ms) TIDAK MENJAMIN internet enak dipakai.
// Jika ping loncat-loncat (20ms -> 150ms -> 20ms), itu namanya "High Jitter".
// Efeknya:
// - Game: Teleport/Lag Spike (Musuh tiba-tiba pindah).
// - Zoom: Suara robot atau video putus-putus.
// - Streaming: Buffering mendadak.
//
// --- METRIK YANG DIHITUNG ---
// 1. Latency (Real-time): Kecepatan respons saat ini (per 10 detik).
// 2. Packet Loss: Persentase data yang hilang di jalan.
// 3. Jitter (Real-time): Variasi latency antar paket saat ini.
// 4. Session Jitter (Long-term): Rata-rata variasi selama aplikasi dibuka.
// 5. Max Jitter (Worst Case): Lonjakan terparah yang pernah terekam sesi ini.
//
// --- RUMUS PERHITUNGAN ---
// 1. Latency  = (Waktu Terima - Waktu Kirim)
// 2. Jitter   = |Latency_Sekarang - Latency_Sebelumnya| (Nilai Absolute)
// 3. Loss %   = ((Total Kirim - Total Terima) / Total Kirim) * 100
// 4. Session Avg = Total Semua Nilai / Total Jumlah Sampel
//
// =================================================================================

struct PingResult {
    // Data Sesaat (Real-time / 10 detik terakhir) -> Buat Speedometer
    let latencyMs: Double
    let jitterMs: Double
    let packetLossPercentage: Double
    
    // Data Jangka Panjang (Session / Reputasi Tempat) -> Buat Status "Elite/Lag"
    let sessionAvgLatency: Double
    let sessionAvgJitter: Double
    let sessionMaxJitter: Double // Rekor terburuk (Penting buat deteksi lag spike)
}

class PingService: NSObject, SimplePingDelegate {
    
    static let shared = PingService()
    
    // Callback ke ViewModel
    var onPingUpdate: ((PingResult) -> Void)?
    var onError: ((String) -> Void)?
    
    private var pinger: SimplePing!
    private let hostName: String = "8.8.8.8"
    private var sendDate: Date?
    private var pingTimer: Timer?
    
    // --- BUFFER REALTIME (Untuk Speedometer) ---
    // Direset setiap kali lapor (tiap 10 sampel)
    private var pingBuffer: [Double] = []
    private var sentCounter: Int = 0
    private var targetSamples: Int = 5
    
    // --- SESSION STATS (Untuk Reputasi Tempat) ---
    // Tidak direset sampai user stop/keluar app
    private var totalSessionLatency: Double = 0.0
    private var totalSessionJitter: Double = 0.0
    private var totalSessionCount: Int = 0
    private var maxRecordedJitter: Double = 0.0
    
    // Helper untuk hitung jitter (perlu tau ping sebelumnya)
    private var previousLatency: Double? = nil
    private var currentBatchJitterSum: Double = 0.0
    
    private(set) var currentResult: PingResult?
    
    override init() {
        super.init()
    }
    
    func startMonitoring() {
        guard pinger == nil else { return }
        
        // Reset State Awal
        resetRealtimeBuffer()
        resetSessionStats()
        
        startContinuousPing()
    }
    
    func stopMonitoring() {
        pinger?.stop()
        pinger = nil
        pingTimer?.invalidate()
        pingTimer = nil
        resetRealtimeBuffer()
    }
    
    private func resetRealtimeBuffer() {
        pingBuffer.removeAll()
        sentCounter = 0
        targetSamples = 5 // Awal mulai 5 biar cepet, nanti jadi 10
        currentBatchJitterSum = 0.0
        previousLatency = nil // Reset prev latency tiap batch biar jitter fresh
    }
    
    private func resetSessionStats() {
        totalSessionLatency = 0.0
        totalSessionJitter = 0.0
        totalSessionCount = 0
        maxRecordedJitter = 0.0
    }
    
    private func startContinuousPing() {
        pinger = SimplePing(hostName: hostName)
        pinger?.delegate = self
        pinger?.start()
    }
    
    // MARK: - Logic Internal
    @objc private func sendPing() {
        sendDate = Date()
        pinger?.send(with: nil)
        
        sentCounter += 1
        
        // Trigger Lapor setiap target sampel terpenuhi
        if sentCounter >= targetSamples {
            processAndReport()
        }
    }
    
    private func processAndReport() {
        // 1. Hitung Realtime Latency (Average Batch Ini)
        let totalLatency = pingBuffer.reduce(0, +)
        let avgLatency = pingBuffer.isEmpty ? 0.0 : totalLatency / Double(pingBuffer.count)
        
        // 2. Hitung Realtime Jitter (Average Batch Ini)
        // Kita sudah hitung sum-nya secara incremental di 'didReceive'
        // Pembagi dikurangi 1 karena jitter adalah selisih antar 2 titik
        let jitterDivisor = Double(max(1, pingBuffer.count - 1))
        let avgJitter = currentBatchJitterSum / jitterDivisor
        
        // 3. Hitung Packet Loss
        let sent = Double(sentCounter)
        let received = Double(pingBuffer.count)
        let loss = sent > 0 ? ((sent - received) / sent) * 100.0 : 0.0
        let safeLoss = max(0.0, loss)
        
        // 4. Hitung Session Stats (Akumulasi Jangka Panjang)
        // -- Latency Session
        totalSessionLatency += totalLatency
        totalSessionCount += pingBuffer.count
        let sessionAvgLatency = totalSessionCount > 0 ? totalSessionLatency / Double(totalSessionCount) : 0.0
        
        // -- Jitter Session (Total Jitter Accumulation / Total Sampel)
        // Note: Kita approksimasi pembaginya dengan total count
        totalSessionJitter += currentBatchJitterSum
        let sessionAvgJitter = totalSessionCount > 0 ? totalSessionJitter / Double(totalSessionCount) : 0.0
        
        // 5. Bungkus Data
        let result = PingResult(
            latencyMs: avgLatency,
            jitterMs: avgJitter,
            packetLossPercentage: safeLoss,
            sessionAvgLatency: sessionAvgLatency,
            sessionAvgJitter: sessionAvgJitter,
            sessionMaxJitter: maxRecordedJitter
        )
        
        self.currentResult = result
        onPingUpdate?(result)
        
        // 6. Reset Buffer untuk Siklus Berikutnya
        pingBuffer.removeAll()
        sentCounter = 0
        targetSamples = 10 // Selanjutnya per 10 detik
        currentBatchJitterSum = 0.0
        // Note: previousLatency JANGAN di-nil kan di sini, biar jitter nyambung antar batch
    }
    
    // MARK: - SimplePingDelegate
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        DispatchQueue.main.async {
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.sendPing()
            }
        }
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let sendDate = sendDate else { return }
        let latency = Date().timeIntervalSince(sendDate) * 1000
        
        // --- LOGIC HITUNG JITTER INCREMENTAL ---
        // Jitter = Selisih latency sekarang dengan latency sebelumnya
        if let prev = previousLatency {
            let diff = abs(latency - prev)
            
            // Masukkan ke sum batch saat ini
            currentBatchJitterSum += diff
            
            // Cek apakah ini rekor jitter terburuk? (Max Jitter)
            if diff > maxRecordedJitter {
                maxRecordedJitter = diff
            }
        }
        
        // Simpan latency sekarang sebagai "sebelumnya" untuk paket berikutnya
        previousLatency = latency
        // ---------------------------------------
        
        pingBuffer.append(latency)
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: any Error) {
        // Error level socket, biasanya akan terhitung sebagai packet loss di logic processAndReport
        
        // Teruskan ke ViewModel (PENTING: Biar user tau kalau internet putus total/error socket)
        onError?(error.localizedDescription)
    }
}
