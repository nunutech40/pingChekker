//
//  SettingsViewModel.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import SwiftUI
import Combine
import AppKit

class SettingsViewModel: ObservableObject {
    
    @Published var isMonitoring: Bool = false
    
    init() {
        // 1. Langsung ambil status dari "Pusat Kebenaran" (HistoryService)
        self.isMonitoring = HistoryService.shared.isMonitoring
        
        // 2. Dengerin perubahan selanjutnya
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange(_:)),
            name: .monitoringStateChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Handler Notifikasi
    @objc private func handleStateChange(_ notification: Notification) {
        if let status = notification.userInfo?["isMonitoring"] as? Bool {
            DispatchQueue.main.async {
                self.isMonitoring = status
            }
        }
    }
    
    // Fungsi Resume
    func resumeMonitoring() {
        print("▶️ [SettingsVM] Resuming...")
        
        // 1. Kirim Sinyal Start Logic ke HomeViewModel
        NotificationCenter.default.post(name: .startPingSession, object: nil)
        
        // 2. Paksa App Fokus ke Depan (Ini yang lu cari)
        NSApp.activate(ignoringOtherApps: true)
    }
}
