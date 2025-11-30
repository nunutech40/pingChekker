//
//  WifiService.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import Foundation
import CoreWLAN // Framework Wajib buat macOS WiFi

// Model Data Sederhana
struct WifiDetails {
    let ssid: String
    let bssid: String
    let rssi: Int      // Signal Strength (-30 bagus, -90 jelek)
    let noise: Int     // Gangguan sinyal
    let channel: Int
    let band: String   // 2.4GHz or 5GHz
    let security: String
    
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
        
        return WifiDetails(
            ssid: ssid,
            bssid: bssid,
            rssi: rssi,
            noise: noise,
            channel: Int(channel),
            band: band,
            security: sec
        )
    }
}
