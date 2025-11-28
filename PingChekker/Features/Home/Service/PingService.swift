//
//  PingService.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.
//

import Foundation

// =================================================================================
// MARK: - DOKUMENTASI PING SERVICE (MOS + JITTER STATS)
// =================================================================================
//
// Service ini menghitung Latency, MOS, dan Statistik Jitter secara lengkap.
//
// --- METRIK UTAMA ---
// 1. Latency: Kecepatan respons (ms).
// 2. MOS (Mean Opinion Score): Skor kualitas 1-5 (Standar VoIP).
// 3. Jitter Stats:
//    - Realtime: Jitter saat ini (10 detik terakhir).
//    - Session Avg: Rata-rata jitter selama aplikasi nyala (Reputasi).
//    - Max Jitter: Jitter tertinggi yang pernah tercatat (Deteksi Lag Spike).
//
// =================================================================================

struct PingResult {
    // Data Speedometer & Realtime
    let latencyMs: Double
    let jitterMs: Double
    let packetLossPercentage: Double
    let mosScore: Double // Skor MOS Sesaat
    
    // Data Sesi (Reputasi Tempat) - Penting buat ViewModel
    let sessionAvgLatency: Double
    let sessionAvgJitter: Double
    let sessionMaxJitter: Double // Rekor terburuk
    let sessionMOS: Double
}
class PingService: NSObject, SimplePingDelegate, PingServiceProtocol {
    
    static let shared = PingService()
    
    // Conformance to Protocol
    var onPingUpdate: ((PingResult) -> Void)?
    var onError: ((String) -> Void)?
    
    private var pinger: SimplePing!
    
    // Ambil dari SettingsStore (Var biar bisa diupdate)
    private var hostName: String = SettingsStore.shared.targetHost
    
    private var sendDate: Date?
    private var pingTimer: Timer?
    private var retryTimer: Timer?
    
    // --- BUFFER REALTIME ---
    private var pingBuffer: [Double] = []
    private var sentCounter: Int = 0
    private var targetSamples: Int = 5
    
    // --- JITTER HELPER ---
    private var currentBatchJitterSum: Double = 0.0
    private var previousLatency: Double? = nil
    
    // --- SESSION STATS ---
    private var totalSessionLatencySum: Double = 0.0
    private var totalSessionJitterSum: Double = 0.0
    private var totalSessionReceivedCount: Int = 0
    private var totalSessionSentCount: Int = 0
    private var maxRecordedJitter: Double = 0.0
    
    override init() {
        super.init()
    }
    
    // MARK: - Protocol Methods
    
    func updateHost(newHost: String) {
        guard newHost != hostName else { return }
        print("🔁 Switching Host: \(hostName) -> \(newHost)")
        hostName = newHost
        stopMonitoring()
        startMonitoring()
    }
    
    func startMonitoring() {
        guard pinger == nil else { return }
        stopMonitoring()
        resetBuffers()
        startPinger()
    }
    
    func stopMonitoring() {
        pinger?.stop()
        pinger = nil
        pingTimer?.invalidate()
        pingTimer = nil
        retryTimer?.invalidate()
        retryTimer = nil
        resetBuffers()
    }
    
    // MARK: - Private Helpers
    
    private func resetBuffers() {
        pingBuffer.removeAll()
        sentCounter = 0
        targetSamples = 5
        currentBatchJitterSum = 0.0
        previousLatency = nil
        
        // Reset Session (Ganti host = Reset statistik)
        totalSessionLatencySum = 0.0
        totalSessionJitterSum = 0.0
        totalSessionReceivedCount = 0
        totalSessionSentCount = 0
        maxRecordedJitter = 0.0
    }
    
    private func startPinger() {
        print("🚀 Starting Pinger to: \(hostName)")
        pinger = SimplePing(hostName: hostName)
        pinger?.delegate = self
        pinger?.start()
    }
    
    @objc private func sendPing() {
        sendDate = Date()
        pinger?.send(with: nil)
        
        sentCounter += 1
        totalSessionSentCount += 1
        
        if sentCounter >= targetSamples {
            processAndReport()
        }
    }
    
    private func processAndReport() {
        // --- DATA SESAAT ---
        let totalLatency = pingBuffer.reduce(0, +)
        let avgLatency = pingBuffer.isEmpty ? 0.0 : totalLatency / Double(pingBuffer.count)
        
        let jitterDivisor = Double(max(1, pingBuffer.count - 1))
        let avgJitter = currentBatchJitterSum / jitterDivisor
        
        let sent = Double(sentCounter)
        let received = Double(pingBuffer.count)
        let loss = sent > 0 ? ((sent - received) / sent) * 100.0 : 0.0
        let safeLoss = max(0.0, min(100.0, loss))
        
        let instantMOS = calculateMOSScore(latency: avgLatency, jitter: avgJitter, loss: safeLoss)
        
        // --- DATA SESI ---
        if received > 0 {
            totalSessionLatencySum += totalLatency
            totalSessionReceivedCount += pingBuffer.count
            totalSessionJitterSum += currentBatchJitterSum
        }
        
        let sessionAvgLat = totalSessionReceivedCount > 0 ? totalSessionLatencySum / Double(totalSessionReceivedCount) : 0.0
        let sessionJitterDivisor = Double(max(1, totalSessionReceivedCount - 1))
        let sessionAvgJit = totalSessionJitterSum / sessionJitterDivisor
        
        let sessionSent = Double(totalSessionSentCount)
        let sessionRecv = Double(totalSessionReceivedCount)
        let sessionLoss = sessionSent > 0 ? ((sessionSent - sessionRecv) / sessionSent) * 100.0 : 0.0
        let safeSessionLoss = max(0.0, min(100.0, sessionLoss))
        
        let sessionMOS = calculateMOSScore(latency: sessionAvgLat, jitter: sessionAvgJit, loss: safeSessionLoss)
        
        // --- LAPOR ---
        let result = PingResult(
            latencyMs: avgLatency,
            jitterMs: avgJitter,
            packetLossPercentage: safeLoss,
            mosScore: instantMOS,
            sessionAvgLatency: sessionAvgLat,
            sessionAvgJitter: sessionAvgJit,
            sessionMaxJitter: maxRecordedJitter,
            sessionMOS: sessionMOS
        )
        
        onPingUpdate?(result)
        
        // Reset Buffer Batch
        pingBuffer.removeAll()
        sentCounter = 0
        targetSamples = 10
        currentBatchJitterSum = 0.0
    }
    
    private func calculateMOSScore(latency: Double, jitter: Double, loss: Double) -> Double {
        if latency == 0 && loss >= 100 { return 1.0 }
        
        let effectiveLatency = latency + (jitter * 2) + 10.0
        var rValue: Double = 0.0
        
        if effectiveLatency < 160 {
            rValue = 93.2 - (effectiveLatency / 40.0)
        } else {
            rValue = 93.2 - ((effectiveLatency - 120.0) / 10.0)
        }
        
        rValue = rValue - (loss * 2.5)
        rValue = max(0.0, min(100.0, rValue))
        
        var mos: Double = 1.0
        if rValue > 0 {
            mos = 1.0 + (0.035 * rValue) + (rValue * (rValue - 60.0) * (100.0 - rValue) * 0.000007)
        }
        return max(1.0, min(5.0, mos))
    }
    
    // MARK: - SimplePingDelegate
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        retryTimer?.invalidate()
        DispatchQueue.main.async {
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.sendPing()
            }
        }
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let sendDate = sendDate else { return }
        let latency = Date().timeIntervalSince(sendDate) * 1000
        
        if let prev = previousLatency {
            let diff = abs(latency - prev)
            currentBatchJitterSum += diff
            if diff > maxRecordedJitter { maxRecordedJitter = diff }
        }
        previousLatency = latency
        
        pingBuffer.append(latency)
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: any Error) {
        print("Ping Error: \(error.localizedDescription)")
        onError?(error.localizedDescription)
        
        stopMonitoring()
        retryTimer?.invalidate()
        retryTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.startMonitoring()
        }
    }
}
