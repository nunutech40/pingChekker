//
//  WifiDetailViewModel.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import SwiftUI
import Combine

class WifiDetailViewModel: ObservableObject {
    
    // Output UI
    @Published var wifiInfo: WifiDetails?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Timer untuk auto-refresh sinyal (RSSI berubah-ubah)
    private var timer: Timer?
    
    init() {
        // Fetch data awal
        refreshData()
    }
    
    // Pastikan timer mati kalau ViewModel dibuang
    deinit {
        stopLiveUpdate()
    }
    
    // MARK: - Actions
    
    func startLiveUpdate() {
        // Safety: Matikan timer lama kalau ada
        stopLiveUpdate()
        
        // Update tiap 2 detik agar indikator sinyal hidup
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.refreshData()
        }
    }
    
    func stopLiveUpdate() {
        timer?.invalidate()
        timer = nil
    }
    
    func refreshData() {
        // Ambil data dari Service
        if let details = WifiService.shared.fetchCurrentWifiInfo() {
            DispatchQueue.main.async {
                self.wifiInfo = details
                self.errorMessage = nil
            }
        } else {
            DispatchQueue.main.async {
                // 🔥 FIX: GANTI PESAN ERROR JADI ENGLISH KEY
                // (Teks ini sudah ada terjemahannya di Localizable.xcstrings)
                self.errorMessage = "No Wi-Fi interface found or location permission denied. Please ensure Wi-Fi is on and permissions are granted in System Settings."
                self.wifiInfo = nil
            }
        }
    }
    
    // MARK: - UI Helpers
    
    // Menentukan warna bar sinyal berdasarkan kekuatan dBm
    func getSignalColor(_ rssi: Int) -> Color {
        switch rssi {
        case -50...0: return .green        // Sangat Bagus
        case -70 ..< -50: return .yellow   // Bagus/Cukup
        case -80 ..< -70: return .orange   // Lemah
        default: return .red               // Buruk/Hampir Putus
        }
    }
}
