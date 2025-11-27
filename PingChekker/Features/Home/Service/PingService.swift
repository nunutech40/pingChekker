//
//  PingService.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.

import Foundation

class PingService: NSObject, SimplePingDelegate {
    
    static let shared = PingService()
    
    var onPingUpdate: ((Double) -> Void)?
    var onError: ((String) -> Void)?
    
    private var pinger: SimplePing!
    private let hostName: String = "8.8.8.8"
    private var sendDate: Date?
    private var pingTimer: Timer?
    
    // Penampung data (Passive Storage)
    private var pingBuffer: [Double] = []
    
    // --- SETTINGAN BARU ---
    // Counter berjalan (0, 1, 2, 3...)
    private var sampleCounter: Int = 0
    
    // Target sample (Variable Global Class biar bisa diubah logicnya)
    // Start awal 5, nanti berubah jadi 10
    private var targetSamples: Int = 5
    
    private(set) var currentAverageLatency: Double = 0.0
    
    override init() {
        super.init()
    }
    
    func startMonitoring() {
        guard pinger == nil else { return }
        
        // Reset Logic
        targetSamples = 5
        sampleCounter = 0
        pingBuffer.removeAll()
        
        startContinuousPing()
    }
    
    func stopMonitoring() {
        pinger?.stop()
        pinger = nil
        pingTimer?.invalidate()
        pingTimer = nil
        pingBuffer.removeAll()
        sampleCounter = 0
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
        
        // 1. NAIKKAN COUNTER (Setiap detik/setiap kirim)
        sampleCounter += 1
        
        // 2. CEK APAKAH SUDAH WAKTUNYA LAPOR?
        if sampleCounter >= targetSamples {
            processAndReport()
        }
    }
    
    // Fungsi khusus buat ngitung & lapor
    private func processAndReport() {
        // Cek dulu buffer kosong gak (takutnya RTO semua / Packet Loss 100%)
        if !pingBuffer.isEmpty {
            let total = pingBuffer.reduce(0, +)
            let average = total / Double(pingBuffer.count)
            
            self.currentAverageLatency = average
            onPingUpdate?(average)
            
            print("Reported: \(average) ms. (Data collected: \(pingBuffer.count)/\(targetSamples))")
        } else {
            // Kalau buffer kosong pas waktunya lapor, berarti RTO parah
            onError?("Request Timed Out (No Response)")
        }
        
        // 3. RESET & UPDATE TARGET
        pingBuffer.removeAll()
        sampleCounter = 0
        
        // Logic ganti target: Set jadi 10 seterusnya
        targetSamples = 10
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
        
        // Logic di sini sekarang "BODO AMAT".
        // Ada barang masuk? Masukin keranjang.
        // Gak urus kapan harus lapor. Itu urusan sendPing/Counter.
        pingBuffer.append(latency)
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: any Error) {
        // Error handling standar
        onError?(error.localizedDescription)
        stopMonitoring()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.startMonitoring()
        }
    }
}
