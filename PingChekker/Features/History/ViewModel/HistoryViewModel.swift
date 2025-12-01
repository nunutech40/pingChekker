//
//  HistoryViewModel.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import SwiftUI
import CoreData

class HistoryViewModel: ObservableObject {
    
    @Published var activeID: UUID?
    // --- STATE BUAT ALERT ---
    @Published var showRunningAlert: Bool = false
    @Published var showDeleteConfirmation: Bool = false
    @Published var showClearAllConfirmation: Bool = false
    
    private let service: HistoryService
    
    // Nampung korban yang mau dieksekusi
    var itemToDelete: NetworkHistory?
    
    
    // Default-nya tetep .shared biar UI asli gak error
    init(service: HistoryService = .shared) {
        self.service = service
        // 1. Ambil nilai awal saat view dibuka
        self.activeID = service.currentSessionID
        
        // 2. Dengerin perubahan ID (Notification)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionChange(_:)),
            name: NSNotification.Name("currentSessionIDChanged"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleSessionChange(_ notification: Notification) {
        DispatchQueue.main.async {
            // Update state UI kalau ID sesi berubah
            if let id = notification.userInfo?["sessionID"] as? UUID {
                self.activeID = id
            } else {
                self.activeID = nil
            }
        }
    }
    
    // Return True kalau item ini adalah sesi yang lagi jalan
    func isActiveSession(_ item: NetworkHistory) -> Bool {
        guard let currentID = activeID else { return false }
        return item.id == currentID
    }
    
    // Format tanggal sesuai request aneh lo: "17-08-1990:12.30"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy:HH.mm" // Format custom
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }()
    
    // --- HELPERS ---
    
    func getFormattedDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        return dateFormatter.string(from: date)
    }
    
    func deleteAll() {
        // 1. TERIAK DULU KE HOMEVIEWMODEL
        // "Woi stop! Gue mau bakar gudang!"
        NotificationCenter.default.post(name: .resetPingSession, object: nil)
        
        // Kasih jeda dikit (nanosecond) biar HomeViewModel sempet lepas tangan
        // (Sebenernya gak wajib delay karena NotificationCenter itu synchronous by default, tapi aman)
        
        // 2. BARU HAPUS DATA
        service.deleteAll()
        
        print("✅ Command sent & DB Cleared.")
    }
    
    // Logic Hapus Item
    func deleteItem(_ item: NetworkHistory) {
        service.deleteItem(item)
    }
    
    // --- LOGIC MOS TRANSLATOR (Dari HomeViewModel) ---
    // Return Tuple: (StatusText, Color, IconName)
    func evaluateQuality(mos: Double) -> (status: String, color: Color, icon: String) {
        
        // Kalau 0.0, jangan dibilang Critical, tapi "Running"
        if mos == 0.0 {
            return ("Monitoring...", .blue, "hourglass")
        }
        
        // Sisanya sama
        if mos >= 4.3 {
            return ("Excellent", .green, "trophy.fill")
        } else if mos >= 4.0 {
            return ("Good", .green.opacity(0.8), "hand.thumbsup.fill")
        } else if mos >= 3.5 {
            return ("Fair", .yellow, "exclamationmark.shield.fill")
        } else if mos >= 2.5 {
            return ("Poor", .orange, "wifi.exclamationmark")
        } else {
            return ("Critical", .red, "xmark.octagon.fill")
        }
    }
    
    // Fungsi Pemicu (Dipanggil View)
    func requestDelete(item: NetworkHistory) {
        // Cek dulu: Lagi monitoring gak?
        if service.isMonitoring {
            // Kalau IYA: Tampilkan Alert "Stop Dulu"
            showRunningAlert = true
        } else {
            // Kalau ENGGAK: Simpan itemnya, Tampilkan Alert Konfirmasi
            itemToDelete = item
            showDeleteConfirmation = true
        }
    }
    
    // Fungsi Eksekutor (Dipanggil kalau User udah Yakin)
    func confirmDelete() {
        if let item = itemToDelete {
            service.deleteItem(item)
            itemToDelete = nil // Reset
        }
    }
    
    func requestClearAll() {
        // Cek lagi monitoring gak?
        if service.isMonitoring {
            showRunningAlert = true
        } else {
            // Tampilkan alert konfirmasi "Clear All"
            showClearAllConfirmation = true
        }
    }
    
    // --- LOGIC CLEAR ALL (CLEAN) ---
    func confirmClearAll() {
        // Hapus Data (Sekarang UI bakal langsung update karena fix di Service)
        service.deleteAll()
        
        // Kirim sinyal reset logic ke HomeViewModel (biar activeSessionID jadi nil)
        NotificationCenter.default.post(name: .resetPingSession, object: nil)
    }
}
