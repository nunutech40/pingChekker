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
// 1. Lakukan ping menggunakan modul SimplePing milik Apple Developer, dengan host google (8.8.8.8)
// 2. Dapatkan latency (selisih waktu antara pengiriman paket dan response diterima)
// 3. Ping dilakukan setiap 1 detik, dan dimasukan per siklus, siklus ping dilakukan setiap 10 detik dg refresh
// 4. Per siklus dilakukan perhitungan average latency
// 5. Average latency -> menghasilkan status message yang dikategorikan
// 6. Lakukan siklus ping terus menerus hingga applikasi di matikan

import Foundation
import SwiftUICore

class PingStrengthChecker: NSObject, SimplePingDelegate, ObservableObject {
    
    // Published properties untuk update UI
    // Variable observable object utk memantau status message dan average latency dari UI
    @Published var statusMessage: String = "Memulai pengujian..."
    @Published var categoryAveragePing: String = ""
    @Published var statusColor: Color = .gray
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
        // Start continous hanya melakukan sendPing utk siklus ping pertama(di lakukan di fungsi simpePing -> didStartAddress, lalu siklus ping ke dua dan seterusnya dilakukan di refreshstatus
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
    // 3. run function start pada variable object pinger utk memulai ping
    // 4. run schedule utk interval 10 detik dari refresh interfal
    // 5. jadwalkan refreshStatus setiap interval 10 detik dg scheduler
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
    
    // init ping dibutuhkan cepat, jadi hitung average cukup dari 5 ping
    private func initPing() {
        guard pingCount < 5, let pinger = pinger, pinger.hostAddress != nil else { return }
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
    
    // Fungsi categorizePingStrength -> mengkategorikan status message yang ditampilkan ke user berdasarkan averageping
    // Input -> averageping, double
    // Proses: lihat pada switc case nya
    // Output -> Void, merubah value pada variable status message
    private func categorizePingStrength(averagePing: Double) {
        switch averagePing {
        case 0..<21:
            categoryAveragePing = "elite"
            statusColor = .green
        case 21..<51:
            categoryAveragePing = "good"
            statusColor = Color.green.opacity(0.8)
        case 51..<101:
            categoryAveragePing = "good enough"
            statusColor = .yellow
        case 101..<201:
            categoryAveragePing = "enough"
            statusColor = .orange
        case 201..<501:
            categoryAveragePing = "slow"
            statusColor = .red
        case 500...:
            categoryAveragePing = "unplayable"
            statusColor = .purple
        default:
            categoryAveragePing = "no connection"
            statusColor = .gray
        }
        
        // Ambil message dari random message
        statusMessage = PingMessages.getRandomMessage(for: categoryAveragePing)
    }
    
    // MARK: - SimplePingDelegate Methods
    // tiga fungsi simplePing: didStartWithAddress, didReceivePingResponsePacket, didFailWithError adalah fungsi yang diturunkan dari protocol/class SimplePingDelegate
    
    // Fungsi simplePing didStartWithAddress -> Fungsi ini dipanggil otomatis oleh SimplePing saat proses ping dimulai dan alamat host berhasil diresolve
    // Input -> object SimplePing, Object SimplePing dan address (tipe Data) yang merupakan alamat IP host yang diresolve oleh SimplePing
    // Proses:
    // 1. Run scheduler dg interval 1 detik
    // 2. run sendPing di dalam scheduler
    // Output -> void, merubah variable pingtimer
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        // Mulai pengiriman ping setelah hostAddress tersedia
        DispatchQueue.main.async { [weak self] in
            self?.pingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.initPing()
            }
        }
    }
    
    // Fungsi simplePing didReceivePingResponsePacket -> Fungsi ini dipanggil otomatis oleh SimplePing setiap kali ada respons ping (ICMP Echo Reply) yang diterima dari host (misalnya, 8.8.8.8), setelah pinger.send(with:) dipanggil di sendPing().
    // Input -> object SimplePing dan packet (tipe Data) dan sequenceNumber: UInt16 (nomor urut paket), dari SimplePing yang mengirimkan data ke delegate
    // Proses:
    // 1. Overide function simplePing dari protocol SimplePingDelegate
    // 2. get sendDate
    // 3. get latency dari: menghitung selisih waktu, antara saat paket dikirim dan saat paket diterima. Dikalikan 1000 utk merubahnya ke ms (di dapatkan dalam bentuk seconds)
    // 4. masukan latency yg di dapat ke dalam array pingResults
    // Output -> void, mempengaruhi dan merubah data pingResults
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let sendDate = sendDate else { return }
        let latency = Date().timeIntervalSince(sendDate) * 1000
        pingResults.append(latency)
    }
    
    // Fungsi simplePing didFailWithError -> Fungsi ini dipanggil secara otomatis oleh SimplePing setiap kali ada response ping yang error.
    // Input -> object SimplePing dan Object Error yang dikirim oleh SimplePing
    // Proses:
    // 1. updata statusMessage dg message error
    // 2. update data averagelatency dg "N/A"
    // 3. lakukan refresh status (reset)
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = "Ping gagal: \(error.localizedDescription)"
            self?.averageLatency = "N/A"
        }
        refreshStatus() // Lanjutkan siklus berikutnya
    }
}
