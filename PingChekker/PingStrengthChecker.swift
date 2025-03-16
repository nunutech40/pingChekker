//
//  PingStrengthChecker.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 16/03/25.
//

import Foundation

class PingStrengthChecker: NSObject, SimplePingDelegate, ObservableObject {
    
    // Published properties untuk update UI
    @Published var statusMessage: String = "Memulai pengujian..."
    @Published var averageLatency: String = "N/A"
    
    // Variable Konfigurasi
    private var pinger: SimplePing?
    private let hostName: String = "8.8.8.8"
    private var sendDate: Date?
    private var pingTimer: Timer?
    private var refreshTimer: Timer?
    private var pingCount: Int = 0
    private let maxPingsPerCycle: Int = 10 // Perbaikan penamaan
    private var pingResults: [Double] = []
    private let refreshInterval: TimeInterval = 10.0 // Perbaikan penamaan
    
    override init() {
        super.init()
        self.startContinuousPing()
        print("cekkkk")
    }
    
    deinit {
        pinger?.stop()
        pingTimer?.invalidate()
        refreshTimer?.invalidate()
    }
    
    private func startContinuousPing() {
        pinger = SimplePing(hostName: hostName)
        pinger?.delegate = self
        pinger?.start()
        
        // Timer untuk refresh status setiap 30 detik
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.refreshStatus()
        }
    }
    
    private func sendPing() {
        guard pingCount < maxPingsPerCycle, let pinger = pinger, pinger.hostAddress != nil else { return }
        sendDate = Date()
        pinger.send(with: nil)
        pingCount += 1
    }
    
    private func refreshStatus() {
        pingTimer?.invalidate()
        pingTimer = nil
        
        if !pingResults.isEmpty {
            let averagePing = pingResults.reduce(0, +) / Double(pingResults.count)
            DispatchQueue.main.async { [weak self] in
                self?.averageLatency = String(format: "%.3f ms", averagePing)
                self?.categorizePingStrength(averagePing: averagePing)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.statusMessage = "Tidak ada data ping yang valid."
                self?.averageLatency = "N/A"
            }
        }
        
        // Reset untuk siklus baru
        pingResults.removeAll()
        pingCount = 0
        
        // Mulai timer baru untuk siklus ping
        pingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func categorizePingStrength(averagePing: Double) {
        switch averagePing {
        case 0..<50:
            statusMessage = "Sangat baik (\(averagePing) ms)\nCoba download database NASA!"
        case 50..<100:
            statusMessage = "Cukup Baik (\(averagePing) ms)\nBisa untuk nonton NETFLIX tetapi mungkin akan buffering di kualitas tinggi."
        case 100..<200:
            statusMessage = "Sedang (\(averagePing) ms)\nMasih bisa akses Grok, tapi slow respon."
        case 200...:
            statusMessage = "Lemah (\(averagePing) ms)\nGak usah chattan daripada gebetanmu merasa kamu slowrespon."
        default:
            statusMessage = "Koneksi bermasalah atau tidak terdeteksi (\(averagePing) ms)"
        }
    }
    
    // MARK: - SimplePingDelegate Methods
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        if let hostAddress = pinger.hostAddress {
            let hostAddressString = hostAddress.map { String(format: "%02x", $0) }.joined()
            print("Host address: \(hostAddressString)")
        } else {
            print("Host address: nil")
        }
        // Mulai pengiriman ping setelah hostAddress tersedia
        DispatchQueue.main.async { [weak self] in
            self?.pingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.sendPing()
            }
        }
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let sendDate = sendDate else { return }
        let latency = Date().timeIntervalSince(sendDate) * 1000
        pingResults.append(latency)
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = "Ping gagal: \(error.localizedDescription)"
            self?.averageLatency = "N/A"
        }
        refreshStatus() // Lanjutkan siklus berikutnya
    }
}
