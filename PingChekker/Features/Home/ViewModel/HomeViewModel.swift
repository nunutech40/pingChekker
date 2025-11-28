//
//  HomeViewModel.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    // ==========================================
    // MARK: - OUTPUT UI (LEFT COLUMN: SPEEDOMETER)
    // ==========================================
    @Published var latencyText: String = "- ms"
    @Published var categoryText: String = "calculating" // Elite, Good, etc
    @Published var statusColor: Color = .gray
    @Published var statusMessage: String = "Menganalisa..." // Pesan Fun
    
    // ==========================================
    // MARK: - OUTPUT UI (RIGHT COLUMN: QUALITY)
    // ==========================================
    @Published var mosScore: String = "0.0"
    @Published var qualityCondition: String = "..." // Excellent, Poor
    @Published var qualityDescription: String = "Menunggu data..." // Rekomendasi Teknis
    @Published var qualityColor: Color = .gray
    @Published var qualityIcon: String = "hourglass"
    
    // Info Tambahan
    @Published var sessionAvgText: String = "-"
    @Published var isOffline: Bool = false
    
    // DEPENDENCY INJECTION: Menerima Protocol, bukan Class konkret
    private var service: PingServiceProtocol
    
    // Init menerima service dari luar (default value: PingService.shared)
    // Ini memudahkan testing nanti (bisa inject MockService)
    init(service: PingServiceProtocol = PingService.shared) {
        self.service = service
        
        setupBinding()
        self.service.startMonitoring()
    }
    
    func setupBinding() {
        // Callback Utama: Menerima PingResult yang sudah dihitung matang oleh Service
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
        // 1. Cek Koneksi Putus (Packet Loss 100%)
        if result.packetLossPercentage >= 100 {
            handleError(msg: "Request Timed Out")
            return
        }
        
        // Reset Error State
        self.isOffline = false
        
        // 2. UPDATE VISUAL KIRI (Realtime / Speedometer)
        updateRealtimeUI(latency: result.latencyMs)
        
        // 3. UPDATE VISUAL KANAN (Quality / MOS)
        // Kita prioritaskan Session MOS (Jangka Panjang) biar stabil
        // Kalau sesi masih baru (0), pake MOS sesaat
        let scoreToJudge = result.sessionMOS > 0 ? result.sessionMOS : result.mosScore
        updateQualityUI(score: scoreToJudge, sessionLatency: result.sessionAvgLatency)
    }
    
    // --- LOGIC 1: SPEEDOMETER (KIRI) ---
    private func updateRealtimeUI(latency: Double) {
        self.latencyText = String(format: "%.0f ms", latency)
        
        // Tentukan Kategori Speedometer (Warna & Status Singkat)
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
        
        // Ambil pesan fun
        self.statusMessage = PingMessages.getRandomMessage(for: categoryText)
    }
    
    // --- LOGIC 2: QUALITY CARD (KANAN) ---
    private func updateQualityUI(score: Double, sessionLatency: Double) {
        self.sessionAvgText = String(format: "Rata-rata Sesi: %.0f ms", sessionLatency)
        self.mosScore = String(format: "%.1f", score)
        
        // Mapping SKOR MOS (1-5) ke Copywriting Rekomendasi
        var recommendationKey = "stable"
        
        if score >= 4.3 {
            // 4.3 - 5.0: Dewa
            qualityCondition = "Excellent (Dewa)"
            qualityColor = .green
            qualityIcon = "trophy.fill"
            recommendationKey = "perfect"
        } else if score >= 4.0 {
            // 4.0 - 4.2: Bagus
            qualityCondition = "Good (Bagus)"
            qualityColor = .green.opacity(0.8)
            qualityIcon = "hand.thumbsup.fill"
            recommendationKey = "stable"
        } else if score >= 3.5 {
            // 3.5 - 3.9: Goyang Dikit
            qualityCondition = "Fair (Cukup)"
            qualityColor = .yellow
            qualityIcon = "exclamationmark.shield.fill"
            recommendationKey = "unstable" // Mengarah ke warning jitter
        } else if score >= 2.5 {
            // 2.5 - 3.4: Lemot/Lag
            qualityCondition = "Poor (Buruk)"
            qualityColor = .orange
            qualityIcon = "wifi.exclamationmark"
            recommendationKey = "laggy"
        } else {
            // 1.0 - 2.4: Hancur
            qualityCondition = "Critical (Hancur)"
            qualityColor = .red
            qualityIcon = "xmark.octagon.fill"
            recommendationKey = "critical"
        }
        
        // Ambil teks panjang dari PingMessages
        self.qualityDescription = PingMessages.getRecommendation(for: recommendationKey)
    }
    
    private func handleError(msg: String) {
        // UI Kiri
        statusMessage = "Terputus"
        statusColor = .gray
        categoryText = "no connection"
        latencyText = "RTO"
        
        // UI Kanan
        qualityCondition = "OFFLINE"
        qualityDescription = PingMessages.getRecommendation(for: "offline")
        qualityColor = .gray
        qualityIcon = "wifi.slash"
        mosScore = "0.0"
        sessionAvgText = "-"
        
        isOffline = true
    }
}
