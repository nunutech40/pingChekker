//
//  WifiService.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import Foundation
import CoreWLAN

// Model Data Sederhana
struct WifiDetails {
    let ssid: String
    let bssid: String
    let rssi: Int      // Signal Strength (-30 bagus, -90 jelek)
    let noise: Int     // Gangguan sinyal
    let channel: Int
    let band: String   // 2.4GHz or 5GHz
    let security: String
    
    // 🔥 DATA BARU (PRO INFO)
    let txRate: Double  // Transmit Rate (Mbps)
    let phyMode: String // Wi-Fi Standard (Wi-Fi 5, 6, etc)
    let interfaceName: String // en0
    let ipAddress: String // Local IP
    
    // Computed Property buat Kualitas Sinyal
    var signalQuality: String {
        switch rssi {
        case -50...0: return "Excellent"
        case -70 ..< -50: return "Good"
        case -80 ..< -70: return "Fair"
        default: return "Poor"
        }
    }
}

class WifiService {
    
    static let shared = WifiService()
    private let client = CWWiFiClient.shared()
    
    private init() {}
    
    func fetchCurrentWifiInfo() -> WifiDetails? {
        // Butuh Entitlement: Location & Wi-Fi Info
        guard let interface = client.interface() else { return nil }
        
        // Ambil data mentah
        let ssid = interface.ssid() ?? "Unknown"
        let bssid = interface.bssid() ?? "00:00:00:00:00:00"
        let rssi = interface.rssiValue()
        let noise = interface.noiseMeasurement()
        let channel = interface.wlanChannel()?.channelNumber ?? 0
        
        // Tentukan Band (Kasarannya)
        let band = channel > 14 ? "5 GHz" : "2.4 GHz"
        
        // Security Type (Simplified)
        var sec = "Open/Unknown"
        if interface.security() != .none {
            sec = "Secured (WPA/WPA2)"
        }
        
        // 🔥 AMBIL DATA PRO
        let txRate = interface.transmitRate() // Mbps
        let intName = interface.interfaceName ?? "?"
        
        // Translate PHY Mode (Bahasa Teknis -> Manusia)
        let phyModeString: String
        switch interface.activePHYMode() {
        case .mode11ax: phyModeString = "Wi-Fi 6 (802.11ax)"
        case .mode11ac: phyModeString = "Wi-Fi 5 (802.11ac)"
        case .mode11n:  phyModeString = "Wi-Fi 4 (802.11n)"
        case .mode11g:  phyModeString = "802.11g"
        case .mode11a:  phyModeString = "802.11a"
        case .mode11b:  phyModeString = "802.11b"
        default:        phyModeString = "Unknown Standard"
        }
        
        // Ambil IP Address (Logic Helper di bawah)
        let ip = getLocalIPAddress(for: intName)
        
        return WifiDetails(
            ssid: ssid,
            bssid: bssid,
            rssi: rssi,
            noise: noise,
            channel: Int(channel),
            band: band,
            security: sec,
            txRate: txRate,
            phyMode: phyModeString,
            interfaceName: intName,
            ipAddress: ip
        )
    }
    
    // Helper: Ngorek sistem buat cari IP Address dari Interface Name (en0)
    private func getLocalIPAddress(for interfaceName: String) -> String {
        var address = "Not Found"
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    if let name = String(cString: (interface?.ifa_name)!, encoding: .utf8), name == interfaceName {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}
