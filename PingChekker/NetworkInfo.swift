//
//  NetworkInfo.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 22/03/25.
//

import Foundation
import CoreWLAN

class WifiInfo: ObservableObject {
    @Published var wifiDetails = WiFiDetails()

    init() {
        fetchWifiInfo()
    }

    private func fetchWifiInfo() {
        var wifiData = WiFiDetails()

        // MARK: - SSID & BSSID via CoreWLAN
        if let interface = CWWiFiClient.shared().interface() {
            wifiData.ssid = interface.ssid() ?? "Unknown"
            wifiData.bssid = interface.bssid() ?? "Unknown"
        }

        // MARK: - IP Address
        if let ip = runShellCommand("ipconfig getifaddr en0") {
            wifiData.ipAddress = ip
        }

        // MARK: - Subnet Mask
        if let subnet = runShellCommand("ipconfig getoption en0 subnet_mask") {
            wifiData.subnetMask = subnet
        }

        // MARK: - Default Gateway
        if let gateway = runShellCommand("netstat -rn | grep default | awk '{print $2}' | head -n 1") {
            wifiData.defaultGateway = gateway
        }

        // MARK: - DNS Server
        if let dns = runShellCommand("scutil --dns | grep 'nameserver' | awk '{print $3}' | head -n 1") {
            wifiData.dnsServer = dns
        }

        // NOTE: Fallback values, karena airport -I tidak bisa diakses
        wifiData.signalStrength = "Unknown"
        wifiData.noiseLevel = "Unknown"
        wifiData.channel = "Unknown"
        wifiData.band = "Unknown"
        wifiData.txRate = "Unknown"
        wifiData.mcsIndex = "Unknown"
        wifiData.countryCode = "Unknown"
        wifiData.securityType = "Unknown"
        wifiData.ipv4RoutingTable = "Unknown"

        DispatchQueue.main.async {
            self.wifiDetails = wifiData
            print("cek wifidetails: \(wifiData)")
        }
    }

    // Fungsi runShellCommand -> untuk nge run string di terminal,
    // Input -> String
    // Proses:
    // 1. Gunakan kelas Process utk merun process eksternal seperti terminal
    // 2. Pipe digunakan utk menangkap output dari process eksternal
    // 3. launchPath = "/bin/sh" -> Jalankan shell standart "sh"
    // 4. "-c", command -> Jalankan command ini sebagai string
    //      Misalnya: runShellCommand("ipconfig getifaddr en0")
    //      Akan dijalankan seperti: sh -c "ipconfig getifaddr en0"
    // 5. process.standardOutput = pipe -> tangkap output ke pipe
    // 6. pipe.fileHandleForReading -> baca data dari output
    // 7. start process yang sudah di setup
    // 8. convert hasil data ke string(dg encoding .utf8), trim line extra
    // 9. return outpunya
    // Output -> String return di terminal
    private func runShellCommand(_ command: String) -> String? {
        let process = Process()
        let pipe = Pipe()

        process.launchPath = "/bin/sh"
        process.arguments = ["-c", command]
        process.standardOutput = pipe

        let fileHandle = pipe.fileHandleForReading
        process.launch()

        let data = fileHandle.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return output?.isEmpty == false ? output : nil
    }
}


struct WiFiDetails {
    var ssid: String = "Unknown"
    var bssid: String = "Unknown"
    var ipAddress: String = "Unknown"
    var subnetMask: String = "Unknown"
    var defaultGateway: String = "Unknown"
    var dnsServer: String = "Unknown"
    var signalStrength: String = "Unknown"
    var noiseLevel: String = "Unknown"
    var channel: String = "Unknown"
    var band: String = "Unknown"
    var txRate: String = "Unknown"
    var mcsIndex: String = "Unknown"
    var countryCode: String = "Unknown"
    var securityType: String = "Unknown"
    var ipv4RoutingTable: String = "Unknown"
}
