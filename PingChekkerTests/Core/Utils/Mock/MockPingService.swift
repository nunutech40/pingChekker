//
//  MockPingService.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//


import Foundation
@testable import PingChekker

class MockPingService: PingServiceProtocol {
    
    // Conformance ke Protocol
    var onPingUpdate: ((PingResult) -> Void)?
    var onError: ((String) -> Void)?
    
    // Variable buat ngecek apakah fungsi dipanggil (Spying)
    var isMonitoringStarted = false
    var isMonitoringStopped = false
    var lastUpdatedHost: String?
    
    func startMonitoring() {
        isMonitoringStarted = true
    }
    
    func stopMonitoring() {
        isMonitoringStopped = true
    }
    
    func updateHost(newHost: String) {
        lastUpdatedHost = newHost
    }
    
    // --- FUNGSI SAKTI BUAT TEST ---
    
    // Kita panggil ini dari Test Case buat nyuntik data palsu
    func simulatePing(latency: Double, packetLoss: Double = 0.0, mos: Double? = nil) {
        
        // Logika Penentuan MOS:
        // 1. Kalau di test case dikasih nilai 'mos', pake itu.
        // 2. Kalau nil, pake logika dummy sederhana (Latency > 100 = Jelek).
        let finalMOS = mos ?? (latency > 100 ? 2.0 : 4.5)
        
        let result = PingResult(
            latencyMs: latency,
            jitterMs: 5.0,
            packetLossPercentage: packetLoss,
            mosScore: finalMOS,
            sessionAvgLatency: latency,
            sessionAvgJitter: 5.0,
            sessionMaxJitter: 10.0,
            sessionMOS: finalMOS
        )
        
        // Kirim ke ViewModel
        onPingUpdate?(result)
    }
    
    func simulateError(msg: String) {
        onError?(msg)
    }
}
