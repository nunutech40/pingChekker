//
//  PingStrengthChecker.swift
//  PingChekker
//  Class yang digunakan untuk init object PingStrengthChecker
//  Berguna untuk mengecek koneksi internet dengan inputan data ping to google / 8.8.8.8
//  dan return berupa message
//
//  Created by Nunu Nugraha on 16/03/25.
//

// Algoritma Ping Checker
// 1. Lakukan ping menggunakan modul SimplePing milik Apple Developer, dilakukan saat init
// 2.
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
    }
    
    deinit {
        pinger?.stop()
        pingTimer?.invalidate()
        refreshTimer?.invalidate()
    }
    
    // Fungsi startContinpusPing -> melakukan initialize SimplePing object dari modul SimplePing dan asign ke variable pinger
    // Input -> input constant dari hostname (google / 8.8.8.8)
    // Proses:
    // 1. Init Simple ping dg hostname dari variable hostname(isinya sudah ditentukan di init variable hostname)
    // 2. object pinger melakukan delegate dari parent PingStrengthChecker ke child class yaitu SimplePing
    //  -> SimplePing adalah object yg meng initiate Protocol SimplePingDelegate
    //  -> Function SimplePingDelegate yang di run di SimplePing akan dikirim ke Parent yaitu class PingStrengthChecker, karena sudah meng extends Protocol PingStrengthChecker
    //  -> Perubahan yang terjadi di SimplePing pada function2 dari protocol SimplePingDelegate, bisa di detect di PingStrengthChecker, pada function(simplePing distart, didreceive, diderror)
    // 3. run function start pada variable object pinger
    // 4. run schedule utk interval 10 detik dari refresh interfal
    // 5. lakukan refreshStatus setiap interval 10 detik dari scheduler
    // Output -> Void -> tetapi merubah variable object pinger dg meng initilizenya dg start, dan melakukan refresh(riset initialize Simple ping dg hostname yg ditentukan)
    private func startContinuousPing() {
        pinger = SimplePing(hostName: hostName)
        pinger?.delegate = self
        pinger?.start()
        
        // Timer untuk refresh status setiap 30 detik
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.refreshStatus()
        }
    }
    
    // Fungsi sendPing -> Melakukan Ping
    // Input -> hostAddress / hostName (yg sudah di simpan di dalam object pinger)
    // Proses:
    // 1. Pastikan ping count < dari cycle (10 kali per ping) dan per ping adalah 1 detik, copas pinger(global) ke pinger(lokal, let pinger), dan host address tidak null
    // 2. Simpan data tanggal setiap kali melakukan Ping (utk memantau date setiap melakukan pin)
    // 3. lakukan ping dg function ping pada object pinger
    // 4. pantau ping counter dg iterasi setiap kali ping
    // Output -> return void -> tapi mempengaruhi variable sendDate, pingCount dan object pinger
    private func sendPing() {
        guard pingCount < maxPingsPerCycle, let pinger = pinger, pinger.hostAddress != nil else { return }
        sendDate = Date()
        pinger.send(with: nil)
        pingCount += 1
    }
    
    // Fungsi refreshStatus -> reset status pingtimer, pingresult, ping count dan memulai ulang sendping
    //                      -> mengubah value variable averageLatency, statusmessage,
    //                      -> siklus sendping yang kedua dan seterusnya dilakukan di refreshstatus
    //                      -> siklus refreshstatus dilakukan setiap 10 detik yang di init di init func -> startContinuousPing
    // Input ->
    // 1. average latency get form average ping
    // 2. status message get from average ping
    // Process:
    // 1. invalidate pingtimer (reset)
    // 2. assign average latency with condition form averageping
    // 3. assign statusMessage with condition from averageping
    // 4. remove all ping result (reset)
    // 5. reset ping count
    // 6. init ulang sceduler untuk sendping
    // Output -> Return void
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
            statusMessage = "Lemah (\(averagePing) ms)\nGak usah chattan, lemot. Ntar dikira slow respon"
        default:
            statusMessage = "Koneksi bermasalah atau tidak terdeteksi (\(averagePing) ms)"
        }
    }
    
    // MARK: - SimplePingDelegate Methods
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        if let hostAddress = pinger.hostAddress {
            print("cell hostAddress: \(hostAddress)")
            let hostAddressString = hostAddress.map { String(format: "%02x", $0) }.joined()
            print("Host address: \(hostAddressString)")
        } else {
            print("Host address: nil")
        }
        // Mulai pengiriman ping setelah hostAddress tersedia
        DispatchQueue.main.async { [weak self] in
            self?.pingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.sendPing()
                print("cek datanya here didstart")
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
