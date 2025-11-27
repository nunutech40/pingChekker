//
//  HomeViewModel.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    // --- OUTPUT VISUAL UTAMA (SPEEDOMETER) ---
    // Menggunakan Latency Realtime (per 10 detik) biar jarum gerak dinamis
    @Published var latencyText: String = "- ms"
    
    // --- OUTPUT STATUS (NAMA PANGGILAN JARINGAN) ---
    // Menggunakan Session Average (Jangka Panjang) biar statusnya tidak berubah-ubah
    // Pesan di sini (statusMessage) sifatnya "Fun/Emosional" (misal: "Wuss ngebut!")
    @Published var categoryText: String = "calculating"
    @Published var statusColor: Color = .gray
    @Published var statusMessage: String = "Menganalisa jaringan..."
    
    // --- OUTPUT DESKRIPTIF (HASIL ANALISA KUALITAS) ---
    // Pesan di sini (connectionRecommendation) sifatnya "Teknis/Saran" (misal: "Cocok buat gaming")
    @Published var connectionCondition: String = "Sedang Memindai..." // Judul kondisi
    @Published var connectionRecommendation: String = "Tunggu sebentar..." // Saran teknis
    @Published var recommendationColor: Color = .gray
    @Published var recommendationIcon: String = "hourglass"
    
    // --- INFO TAMBAHAN (SESSION STATS) ---
    @Published var sessionAvgText: String = "-"
    
    // --- DATA RAW (Opsional buat UI) ---
    @Published var jitterText: String = "0"
    @Published var packetLossText: String = "0%"
    
    private let service = PingService.shared
    
    init() {
        setupBinding()
        service.startMonitoring()
    }
    
    func setupBinding() {
        service.onPingUpdate = { [weak self] result in
            DispatchQueue.main.async {
                self?.processResult(result)
            }
        }
        
        service.onError = { [weak self] errorMsg in
            DispatchQueue.main.async {
                self?.handleError(msg: errorMsg)
            }
        }
    }
    
    private func processResult(_ result: PingResult) {
        // 1. Update Speedometer (Realtime)
        self.latencyText = String(format: "%.0f ms", result.latencyMs)
        
        // 2. Update Raw Data UI
        self.jitterText = String(format: "%.0f", result.jitterMs)
        self.packetLossText = String(format: "%.1f%%", result.packetLossPercentage)
        self.sessionAvgText = String(format: "Rata-rata Sesi: %.0f ms", result.sessionAvgLatency)
        
        // 3. ANALISA KUALITAS (Jitter & Loss) -> Output ke Recommendation (Saran Teknis)
        analyzeNetworkQuality(
            avgLatency: result.sessionAvgLatency,
            avgJitter: result.sessionAvgJitter,
            maxJitter: result.sessionMaxJitter,
            loss: result.packetLossPercentage
        )
        
        // 4. Tentukan Kategori Latency -> Output ke Status Message (Fun Message)
        let metricToJudge = result.sessionAvgLatency > 0 ? result.sessionAvgLatency : result.latencyMs
        updateCategory(latency: metricToJudge)
        
        // 5. Refresh Pesan Fun
        self.statusMessage = PingMessages.getRandomMessage(for: categoryText)
    }
    
    // --- LOGIC INTI: MENENTUKAN KEY REKOMENDASI ---
    private func analyzeNetworkQuality(avgLatency: Double, avgJitter: Double, maxJitter: Double, loss: Double) {
        
        var recommendationKey = "stable" // Default key
        
        // PRIORITAS 1: Packet Loss (Musuh Terbesar)
        if loss >= 1.0 {
            connectionCondition = "Koneksi Bocor (Packet Loss)"
            recommendationKey = "packet_loss"
            recommendationColor = .red
            recommendationIcon = "network.slash"
        }
        // PRIORITAS 2: Kestabilan (Jitter)
        else if avgJitter > 50 || maxJitter > 200 {
            connectionCondition = "Tidak Stabil (Goyang)"
            recommendationKey = "unstable"
            recommendationColor = .orange
            recommendationIcon = "waveform.path.ecg"
        }
        // PRIORITAS 3: Kecepatan (Latency) - Jika Loss 0% & Stabil
        else if avgLatency < 40 {
            connectionCondition = "Sangat Stabil & Cepat"
            recommendationKey = "perfect"
            recommendationColor = .green
            recommendationIcon = "checkmark.shield.fill"
        } else if avgLatency < 100 {
            connectionCondition = "Stabil (Standar)"
            recommendationKey = "stable"
            recommendationColor = .green.opacity(0.8)
            recommendationIcon = "hand.thumbsup.fill"
        } else if avgLatency < 200 {
            connectionCondition = "Lambat tapi Stabil"
            recommendationKey = "laggy"
            recommendationColor = .yellow
            recommendationIcon = "tortoise.fill"
        } else {
            connectionCondition = "Koneksi Sangat Lambat"
            recommendationKey = "critical"
            recommendationColor = .red
            recommendationIcon = "exclamationmark.triangle.fill"
        }
        
        // Ambil teks panjang dari PingMessages berdasarkan Key yang ditentukan di atas
        self.connectionRecommendation = PingMessages.getRecommendation(for: recommendationKey)
    }
    
    private func updateCategory(latency: Double) {
        switch latency {
        case 0..<21:
            categoryText = "elite"; statusColor = .green
        case 21..<51:
            categoryText = "good"; statusColor = .green.opacity(0.8)
        case 51..<101:
            categoryText = "good enough"; statusColor = .yellow
        case 101..<201:
            categoryText = "enough"; statusColor = .orange
        case 201..<501:
            categoryText = "slow"; statusColor = .red
        case 501...:
            categoryText = "unplayable"; statusColor = .purple
        default:
            categoryText = "no connection"; statusColor = .gray
        }
    }
    
    private func handleError(msg: String) {
        statusMessage = msg // Tampilkan error teknis di pill pesan
        statusColor = .gray
        categoryText = "unknown"
        latencyText = "- ms"
        
        // Set kondisi gangguan
        connectionCondition = "Gangguan Terdeteksi"
        connectionRecommendation = PingMessages.getRecommendation(for: "offline")
        recommendationColor = .gray
        recommendationIcon = "xmark.circle"
    }
}
