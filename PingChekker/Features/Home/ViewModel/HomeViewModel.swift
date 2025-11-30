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
    // GANTI JADI KEY ENGLISH
    @Published var categoryText: String = "CALCULATING"
    @Published var statusColor: Color = .gray
    // GANTI JADI KEY ENGLISH
    @Published var statusMessage: String = "Calculating..."
    
    // Quality / MOS (Kanan)
    @Published var mosScore: String = "0.0"
    @Published var qualityCondition: String = "..."
    // GANTI JADI KEY ENGLISH
    @Published var qualityDescription: String = "Waiting for data..."
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - HANDLERS
    
    @objc private func handleStartSignal() {
        print("▶️ RECEIVED START SIGNAL. RESUMING...")
        
        // 1. UPDATE STATUS SERVICE
        HistoryService.shared.isMonitoring = true
        
        // 2. RESET TAMPILAN UI
        DispatchQueue.main.async {
            self.isOffline = false
            // GANTI KEY ENGLISH
            self.statusMessage = "Reconnecting..."
            self.categoryText = "CALCULATING"
            self.statusColor = .yellow
            self.qualityCondition = "STARTING..."
            
            self.currentLatency = 0
            self.latencyText = "..."
        }
        
        // 3. JALANKAN MESIN
        service.startMonitoring()
    }
    
    @objc private func handleResetSignal() {
        print("☢️ RECEIVED RESET SIGNAL. NUKING SESSION...")
        
        // 1. JANGAN FINALIZE SESI INI.
        activeSessionID = nil
        lastGoodResult = nil
        
        // 2. Reset UI ke Nol
        DispatchQueue.main.async {
            self.currentLatency = 0
            self.latencyText = "Reset..."
            self.mosScore = "0.0"
            // GANTI KEY ENGLISH
            self.categoryText = "CALCULATING"
            self.statusColor = .gray
            self.statusMessage = "Restarting..."
            self.qualityCondition = "..."
        }
    }
    
    // ==========================================
    // MARK: - MAIN PROCESS LOOP
    // ==========================================
    
    private func processResult(_ result: PingResult) {
        // 1. CEK RTO
        if result.packetLossPercentage >= 100 {
            handleError(msg: "Request Timed Out")
            return
        }
        
        // Reset Error State
        if isOffline { self.isOffline = false }
        
        // 2. SIMPAN DATA VALID
        self.lastGoodResult = result
        
        // 3. LOGIC START SESSION (DRAFT)
        if activeSessionID == nil {
            print("🔍 Checking DB for existing session...")
            
            // Restore Visual dulu
            checkAndRestoreHistory()
            
            // Initialize Session (Upsert Logic)
            self.activeSessionID = HistoryService.shared.initializeSession(
                host: SettingsStore.shared.targetHost
            )
        }
        
        // 4. UPDATE UI REALTIME
        updateRealtimeUI(latency: result.latencyMs)
        
        // 5. UPDATE UI QUALITY
        let scoreToJudge = result.sessionMOS > 0 ? result.sessionMOS : result.mosScore
        updateQualityUI(score: scoreToJudge, sessionLatency: result.sessionAvgLatency)
    }
    
    private func handleError(msg: String) {
        // --- LOGIC DISCONNECT / FINALIZE ---
        
        HistoryService.shared.isMonitoring = false
        
        if !isOffline {
            print("⚠️ Disconnect Detected. Finalizing Session...")
            
            if let sessionID = activeSessionID, let validData = lastGoodResult {
                HistoryService.shared.updateSession(
                    id: sessionID,
                    latency: validData.latencyMs,
                    mos: validData.sessionMOS > 0 ? validData.sessionMOS : validData.mosScore,
                    status: categoryText
                )
            } else {
                print("⚠️ Warning: No active session to finalize.")
            }
            
            activeSessionID = nil
            lastGoodResult = nil
        }
        
        // Update UI jadi Tampilan Offline
        setOfflineState()
    }
    
    // ==========================================
    // MARK: - HELPER FUNCTIONS
    // ==========================================
    
    private func checkAndRestoreHistory() {
        let currentHost = SettingsStore.shared.targetHost
        let currentNet = HistoryService.shared.getWiFiName()
        
        if let lastLog = HistoryService.shared.fetchLastLog(forHost: currentHost, networkName: currentNet) {
            print("♻️ History Found! Restoring MOS: \(lastLog.mos)")
            
            DispatchQueue.main.async {
                self.mosScore = String(format: "%.1f", lastLog.mos)
                self.qualityCondition = lastLog.status ?? "UNKNOWN"
            }
        } else {
            print("🆕 No History. Starting fresh.")
        }
    }
    
    private func setOfflineState() {
        // GANTI KEY ENGLISH
        statusMessage = "Disconnected"
        statusColor = .gray
        categoryText = "NO CONNECTION"
        latencyText = "RTO"
        
        qualityCondition = "OFFLINE"
        qualityDescription = PingMessages.getRecommendation(for: "offline")
        qualityColor = .gray
        qualityIcon = "wifi.slash"
        
        mosScore = "0.0"
        sessionAvgText = "-"
        
        isOffline = true
    }
    
    // ==========================================
    // MARK: - UI UPDATERS (LOGIC WARNA)
    // ==========================================
    
    private func updateRealtimeUI(latency: Double) {
        self.currentLatency = latency
        self.latencyText = String(format: "%.0f ms", latency)
        
        // GANTI JADI ENGLISH UPPERCASE KEYS (Biar match sama Localizable.xcstrings)
        switch latency {
        case 0..<21:
            categoryText = "ELITE"; statusColor = .green
        case 21..<51:
            categoryText = "GOOD"; statusColor = .green.opacity(0.8)
        case 51..<101:
            categoryText = "GOOD ENOUGH"; statusColor = .yellow
        case 101..<201:
            categoryText = "ENOUGH"; statusColor = .orange
        case 201..<501:
            categoryText = "SLOW"; statusColor = .red
        case 501...:
            categoryText = "UNPLAYABLE"; statusColor = .purple
        default:
            categoryText = "NO CONNECTION"; statusColor = .gray
        }
        
        // Note: PingMessages butuh key lowercase buat nyari di dictionary-nya
        self.statusMessage = PingMessages.getRandomMessage(for: categoryText.lowercased())
    }
    
    private func updateQualityUI(score: Double, sessionLatency: Double) {
        // Format String manual
        self.sessionAvgText = String(format: "Session Avg: %.0f ms", sessionLatency)
        self.mosScore = String(format: "%.1f", score)
        
        if score == 0.0 {
            // GANTI KEY ENGLISH
            qualityCondition = "MONITORING..."
            qualityColor = .blue
            qualityIcon = "hourglass"
            qualityDescription = "Collecting initial data..."
            return
        }
        
        var recommendationKey = "stable"
        
        // GANTI KEY ENGLISH
        if score >= 4.3 {
            qualityCondition = "EXCELLENT"
            qualityColor = .green
            qualityIcon = "trophy.fill"
            recommendationKey = "perfect"
        } else if score >= 4.0 {
            qualityCondition = "GOOD"
            qualityColor = .green.opacity(0.8)
            qualityIcon = "hand.thumbsup.fill"
            recommendationKey = "stable"
        } else if score >= 3.5 {
            qualityCondition = "FAIR"
            qualityColor = .yellow
            qualityIcon = "exclamationmark.shield.fill"
            recommendationKey = "unstable"
        } else if score >= 2.5 {
            qualityCondition = "POOR"
            qualityColor = .orange
            qualityIcon = "wifi.exclamationmark"
            recommendationKey = "laggy"
        } else {
            qualityCondition = "CRITICAL"
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
    func forceStopSession() {
        print("FORCE STOP TRIGGERED")
        // Panggil logic finalize yang udah ada
        handleError(msg: "Force Stop")
        // Matikan mesin
        service.stopMonitoring()
    }
}
