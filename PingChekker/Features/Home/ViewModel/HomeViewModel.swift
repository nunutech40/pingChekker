//
//  HomeViewModel.swift
//  PingChekker
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    // ==========================================
    // MARK: - UI PROPERTIES (PUBLISHED)
    // ==========================================
    
    // Speedometer (Kiri)
    @Published var currentLatency: Double = 0.0
    @Published var latencyText: String = "- ms"
    @Published var categoryText: String = "calculating"
    @Published var statusColor: Color = .gray
    @Published var statusMessage: String = "Menganalisa..."
    
    // Quality / MOS (Kanan)
    @Published var mosScore: String = "0.0"
    @Published var qualityCondition: String = "..."
    @Published var qualityDescription: String = "Menunggu data..."
    @Published var qualityColor: Color = .gray
    @Published var qualityIcon: String = "hourglass"
    
    // Footer / Misc
    @Published var sessionAvgText: String = "-"
    @Published var isOffline: Bool = false
    
    // ==========================================
    // MARK: - LOGIC PROPERTIES
    // ==========================================
    
    private var service: PingServiceProtocol
    
    // Data valid terakhir sebelum RTO (buat disave)
    private var lastGoodResult: PingResult?
    
    // ID Session Database (UUID). Kalau nil = Belum ada di DB (Draft).
    private var activeSessionID: UUID?
    
    // ==========================================
    // MARK: - INIT & BINDING
    // ==========================================
    
    init(service: PingServiceProtocol = PingService.shared) {
        self.service = service
        setupBinding()
        
        // FIX SET STATUS LANGSUNG PAS START
        HistoryService.shared.isMonitoring = true
        self.service.startMonitoring()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleResetSignal), name: .resetPingSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStartSignal), name: .startPingSession, object: nil)
    }
    
    func setupBinding() {
        service.onPingUpdate = { [weak self] result in
            DispatchQueue.main.async { self?.processResult(result) }
        }
        
        service.onError = { [weak self] errorMsg in
            DispatchQueue.main.async { self?.handleError(msg: errorMsg) }
        }
    }
    
    @objc private func handleStartSignal() {
        
        // 1. UPDATE STATUS SERVICE (Biar Tombol Settings jadi Disabled/Abu)
        HistoryService.shared.isMonitoring = true
        
        // 2. RESET TAMPILAN UI (Biar Gak Offline Lagi)
        DispatchQueue.main.async {
            //  INI KUNCINYA: Paksa UI jadi Online
            self.isOffline = false
            
            self.statusMessage = "Menghubungkan kembali..."
            self.categoryText = "calculating"
            self.statusColor = .yellow
            self.qualityCondition = "Starting..."
            
            // Reset angka juga biar keliatan mulai dari nol
            self.currentLatency = 0
            self.latencyText = "..."
        }
        
        // 3. JALANKAN MESIN
        service.startMonitoring()
    }
    
    @objc private func handleResetSignal() {
        print("☢️ RECEIVED RESET SIGNAL. NUKING SESSION...")
        
        // 1. JANGAN FINALIZE SESI INI.
        // Karena user minta "Clear All", berarti sesi sekarang juga dianggap sampah.
        // Kita langsung putuskan hubungan dengan DB.
        activeSessionID = nil
        lastGoodResult = nil
        
        // 2. Reset UI ke Nol (Visual Reset)
        DispatchQueue.main.async {
            self.currentLatency = 0
            self.latencyText = "Reset..."
            self.mosScore = "0.0"
            self.categoryText = "calculating"
            self.statusColor = .gray
            self.statusMessage = "Memulai ulang..."
            self.qualityCondition = "..."
        }
        
        // 3. Restart Logic (Biar nanti pas Ping masuk lagi, dia bikin Draft baru)
        // Kita gak perlu stop service pinger-nya, cukup reset state logic-nya aja.
        // Nanti pas 'processResult' jalan lagi (detik berikutnya), dia bakal liat:
        // "Eh activeSessionID nil? Yaudah bikin Draft baru."
    }
    
    // Pastikan remove observer pas mati (opsional di App lifecycle, tapi good practice)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // ==========================================
    // MARK: - MAIN PROCESS LOOP
    // ==========================================
    
    private func processResult(_ result: PingResult) {
        // CEK RTO (FATAL)
        if result.packetLossPercentage >= 100 {
            handleError(msg: "Request Timed Out")
            return
        }
        
        // Reset Error State
        if isOffline { self.isOffline = false }
        
        // 2. SIMPAN DATA VALID (Backup memory)
        self.lastGoodResult = result
        
        // 3. LOGIC START SESSION (DRAFT)
        // Cukup cek activeSessionID. Kalau nil, berarti sesi baru.
        if activeSessionID == nil {
            print("🔍 Checking DB for existing session...")
            
            // Panggil fungsi baru tadi.
            // Dia bakal otomatis milih: Update Tanggal (kalau ada) ATAU Bikin Baru (kalau gak ada).
            self.activeSessionID = HistoryService.shared.initializeSession(
                host: SettingsStore.shared.targetHost
            )
            
            // Logic Restore Visual (Biar UI gak 0.0 kalau ternyata ini resume)
            checkAndRestoreHistory()
        }
        
        // 4. UPDATE UI REALTIME (Speedometer)
        updateRealtimeUI(latency: result.latencyMs)
        
        // 5. UPDATE UI QUALITY (MOS)
        // Prioritaskan Session MOS biar stabil, kecuali masih 0 baru pake Instant MOS
        let scoreToJudge = result.sessionMOS > 0 ? result.sessionMOS : result.mosScore
        updateQualityUI(score: scoreToJudge, sessionLatency: result.sessionAvgLatency)
    }
    
    private func handleError(msg: String) {
        // --- LOGIC DISCONNECT / FINALIZE ---
        
        HistoryService.shared.isMonitoring = false
        
        // Cek flag isOffline biar gak spam save kalau RTO berkali-kali
        if !isOffline {
            print("⚠️ Disconnect Detected. Finalizing Session...")
            
            if let sessionID = activeSessionID, let validData = lastGoodResult {
                // UPDATE Draft tadi dengan data valid terakhir
                HistoryService.shared.updateSession(
                    id: sessionID,
                    latency: validData.latencyMs,
                    mos: validData.sessionMOS > 0 ? validData.sessionMOS : validData.mosScore,
                    status: categoryText // Status terakhir (misal "Good")
                )
            } else {
                print("⚠️ Warning: No active session to finalize.")
            }
            
            // RESET SESI (Penting!)
            // Biar nanti pas konek lagi, dia bikin Draft UUID baru.
            activeSessionID = nil
            lastGoodResult = nil
        }
    
        // Update UI jadi Tampilan Offline
        setOfflineState()
    }
    
    // ==========================================
    // MARK: - HELPER FUNCTIONS
    // ==========================================
    
    // Cek database, kalau ada history host+wifi ini, tampilkan MOS terakhirnya
    private func checkAndRestoreHistory() {
        let currentHost = SettingsStore.shared.targetHost
        let currentNet = HistoryService.shared.getWiFiName()
        
        if let lastLog = HistoryService.shared.fetchLastLog(forHost: currentHost, networkName: currentNet) {
            print("♻️ History Found! Restoring MOS: \(lastLog.mos)")
            
            DispatchQueue.main.async {
                // Cuma update persepsi kualitas, jangan speedometer (biar jujur)
                self.mosScore = String(format: "%.1f", lastLog.mos)
                self.qualityCondition = lastLog.status ?? "Unknown"
                // Kita gak update warna disini biar transisinya natural pas data baru masuk
            }
        } else {
            print("🆕 No History. Starting fresh.")
        }
    }
    
    // Set UI ke mode RTO/Offline
    private func setOfflineState() {
        statusMessage = "Terputus"
        statusColor = .gray
        categoryText = "no connection"
        latencyText = "RTO"
        
        qualityCondition = "OFFLINE"
        qualityDescription = PingMessages.getRecommendation(for: "offline")
        qualityColor = .gray
        qualityIcon = "wifi.slash"
        
        // Reset angka jadi 0 atau strip
        mosScore = "0.0"
        sessionAvgText = "-"
        
        isOffline = true
    }
    
    // ==========================================
    // MARK: - UI UPDATERS (LOGIC WARNA)
    // ==========================================
    
    // Logic Speedometer (Kiri)
    private func updateRealtimeUI(latency: Double) {
        self.currentLatency = latency
        self.latencyText = String(format: "%.0f ms", latency)
        
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
        
        self.statusMessage = PingMessages.getRandomMessage(for: categoryText)
    }
    
    // Logic Quality MOS (Kanan)
    private func updateQualityUI(score: Double, sessionLatency: Double) {
        self.sessionAvgText = String(format: "Rata-rata Sesi: %.0f ms", sessionLatency)
        self.mosScore = String(format: "%.1f", score)
        
        if score == 0.0 {
            qualityCondition = "Monitoring..."
            qualityColor = .blue
            qualityIcon = "hourglass"
            qualityDescription = "Mengumpulkan data awal..."
            return // Keluar fungsi
        }
        
        var recommendationKey = "stable"
        
        if score >= 4.3 {
            qualityCondition = "Excellent (Dewa)"
            qualityColor = .green
            qualityIcon = "trophy.fill"
            recommendationKey = "perfect"
        } else if score >= 4.0 {
            qualityCondition = "Good (Bagus)"
            qualityColor = .green.opacity(0.8)
            qualityIcon = "hand.thumbsup.fill"
            recommendationKey = "stable"
        } else if score >= 3.5 {
            qualityCondition = "Fair (Cukup)"
            qualityColor = .yellow
            qualityIcon = "exclamationmark.shield.fill"
            recommendationKey = "unstable"
        } else if score >= 2.5 {
            qualityCondition = "Poor (Buruk)"
            qualityColor = .orange
            qualityIcon = "wifi.exclamationmark"
            recommendationKey = "laggy"
        } else {
            qualityCondition = "Critical (Hancur)"
            qualityColor = .red
            qualityIcon = "xmark.octagon.fill"
            recommendationKey = "critical"
        }
        
        self.qualityDescription = PingMessages.getRecommendation(for: recommendationKey)
    }
}

// ==========================================
// MARK: - EXTENSIONS
// ==========================================

extension HomeViewModel {
    
    // Fungsi ini dipanggil manual (misal tombol Stop atau Quit App)
    // Memaksa simpan data terakhir ke DB
    func forceStopSession() {
        print("FORCE STOP TRIGGERED")
        // Panggil logic finalize yang udah ada
        handleError(msg: "Force Stop")
        // Matikan mesin
        service.stopMonitoring()
    }
}
