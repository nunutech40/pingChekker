//
//  SettingsViewModel.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    
    // UI Binding
    @Published var isMonitoring: Bool = false
    
    init() {
        // 1. Ambil status awal pas init
        self.isMonitoring = HistoryService.shared.isMonitoring
        
        // 2. Pasang Kuping ke NotificationCenter
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
    
    // Handler pas dapet sinyal dari Service
    @objc private func handleStateChange(_ notification: Notification) {
        if let status = notification.userInfo?["isMonitoring"] as? Bool {
            DispatchQueue.main.async {
                self.isMonitoring = status
            }
        }
    }
    
    // Logic Tombol Resume
    // FUNGSI RESUME (VERSI PREMAN)
    func resumeMonitoring() {
        print("▶️ [SettingsViewModel] User requesting Resume...")
        
        // 1. Kirim Sinyal Start Logic
        NotificationCenter.default.post(name: .startPingSession, object: nil)
        
        DispatchQueue.main.async {
            // 2. Aktifkan Aplikasi dulu
            NSApp.activate(ignoringOtherApps: true)
            
            // 3. CARI JENDELA DASHBOARD
            // Kita cari window yang BUKAN Settings (biasanya window dashboard lebih gede atau judulnya beda)
            // Atau ambil window pertama yang ditemukan
            let dashboardWindow = NSApplication.shared.windows.first { window in
                // Filter: Jangan ambil window Settings (biasanya ukurannya kecil/fixed atau title-nya "Settings")
                // Tips: Lu bisa cek window.title kalau lu set title di HomeView
                return window.title != "Settings" && window.isVisible == true || window.isMiniaturized
            }
            
            if let window = dashboardWindow {
                // 4. PAKSA BANGUN DARI MINIMIZE
                if window.isMiniaturized {
                    window.deminiaturize(nil)
                }
                
                // 5. TARUH PALING DEPAN
                window.makeKeyAndOrderFront(nil)
                print("✅ [SettingsViewModel] Dashboard window forced to front.")
            } else {
                print("⚠️ [SettingsViewModel] Dashboard window not found! (Mungkin ketutup?)")
                // Kalau window beneran ketutup (released), lu butuh logic 'openWindow' (SwiftUI 4+),
                // tapi biasanya di Mac app utility, window cuma di-hide/minimize.
            }
        }
    }
}
