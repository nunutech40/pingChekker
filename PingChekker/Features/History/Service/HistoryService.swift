//
//  HistoryService.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import Foundation
import CoreData
import CoreWLAN

class HistoryService {
    
    static let shared = HistoryService()
    
    // Biar bisa diganti pas test.
    let controller: PresistanceController
    
    // Helper context biar kodingan bawah gak perlu diubah banyak
    private var context: NSManagedObjectContext {
        return controller.container.viewContext
    }
    
    var currentSessionID: UUID? {
        didSet {
            if oldValue != currentSessionID {
                NotificationCenter.default.post(
                    name: NSNotification.Name("currentSessionIDChanged"),
                    object: nil,
                    userInfo: ["sessionID": currentSessionID as Any]
                )
            }
        }
    }
    
    var isMonitoring: Bool = false {
        didSet {
            if oldValue != isMonitoring {
                NotificationCenter.default.post(
                    name: .monitoringStateChanged,
                    object: nil,
                    userInfo: ["isMonitoring": isMonitoring]
                )
            }
        }
    }
    
    init(controller: PresistanceController = PresistanceController.shared) {
        self.controller = controller
    }
    
    // ==========================================
    // MARK: - SESSION LOGIC (MAIN THREAD)
    // ==========================================
    
    func initializeSession(host: String) -> UUID? {
        var activeID: UUID?
        let netInfo = self.getNetworkDetails()
        
        // --- LOGIC BARU: PENCARIAN LEBIH PINTAR (SMART RESUME) ---
        // Alih-alih mencocokkan BSSID secara ketat (yang bikin duplikat kalau roaming/dual-band),
        // Kita cari berdasarkan HOST + SSID dulu, lalu cek waktunya.
        
        context.performAndWait {
            let request: NSFetchRequest<NetworkHistory> = NetworkHistory.fetchRequest()
            
            // 1. Cari berdasarkan Host & SSID saja (abaikan BSSID dulu)
            request.predicate = NSPredicate(
                format: "host == %@ AND networkName == %@",
                host,
                netInfo.ssid
            )
            
            // 2. AMBIL YANG PALING BARU (PENTING!)
            // Tanpa ini, kita bisa mengambil history tahun lalu secara acak.
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            request.fetchLimit = 1
            
            do {
                let results = try context.fetch(request)
                let existingLog = results.first
                
                // 3. TENTUKAN APAKAH BOLEH RESUME?
                var shouldResume = false
                
                if let log = existingLog, let logDate = log.timestamp {
                    // Hitung selisih waktu dari terakhir kali sesi itu aktif
                    let timeGap = Date().timeIntervalSince(logDate)
                    
                    // Batas waktu toleransi untuk resume (misal: 6 Jam).
                    // Jika user kembali dalam 6 jam, kita anggap masih sesi yang sama (resume).
                    // Jika lebih dari 6 jam, kita anggap sesi baru (misal: kerja pagi vs lembur malam).
                    let resumeThreshold: TimeInterval = 6 * 60 * 60 // 6 Jam
                    
                    if timeGap < resumeThreshold {
                        shouldResume = true
                    }
                }
                
                if shouldResume, let log = existingLog {
                    // --- RESUME SESSION ---
                    // Update timestamp biar naik ke paling atas
                    log.timestamp = Date()
                    log.status = "Monitoring..."
                    
                    // Update BSSID ke yang terbaru (menangani kasus roaming Mesh WiFi)
                    // Jadi kalau pindah dari Lt1 ke Lt2, history-nya tetap satu, tapi BSSID-nya update.
                    log.bssid = netInfo.bssid
                    
                    activeID = log.id
                    
                    // Debug Log
                    print("[HistoryService] Resuming session: \(log.networkName ?? "?") (Gap: \(String(format: "%.0fs", Date().timeIntervalSince(log.timestamp ?? Date()))))")
                    
                } else {
                    // --- CREATE NEW SESSION ---
                    // Karena tidak ada history, atau history terakhir sudah terlalu lama (basi).
                    let newLog = NetworkHistory(context: context)
                    activeID = UUID()
                    newLog.id = activeID
                    newLog.timestamp = Date()
                    newLog.host = host
                    newLog.networkName = netInfo.ssid
                    newLog.bssid = netInfo.bssid
                    newLog.latency = 0.0
                    newLog.mos = 0.0
                    newLog.status = "Monitoring..."
                    
                    print("[HistoryService] Creating NEW session: \(netInfo.ssid)")
                }
                
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print("[HistoryService] Init failed: \(error)")
            }
        }
        self.currentSessionID = activeID
        
        return activeID
    }
    
    func updateSession(id: UUID, latency: Double, mos: Double, status: String) {
        // GANTI perform -> performAndWait (Biar Test Gak Balapan)
        context.performAndWait { // Gak perlu wait, fire and forget
            let request: NSFetchRequest<NetworkHistory> = NetworkHistory.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            if let log = try? self.context.fetch(request).first {
                log.latency = latency
                log.mos = mos
                log.status = status
                
                try? self.context.save()
            }
        }
        
        self.currentSessionID = nil
    }
    
    // ==========================================
    // MARK: - HELPERS
    // ==========================================
    
    func fetchLastLog(forHost host: String, networkName: String) -> NetworkHistory? {
        let request: NSFetchRequest<NetworkHistory> = NetworkHistory.fetchRequest()
        request.predicate = NSPredicate(format: "host == %@ AND networkName == %@", host, networkName)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    func deleteAll() {
        // Karena kita pake viewContext (Main Thread), batch delete agak tricky update UI-nya.
        // Cara paling aman & reaktif buat main context: Fetch lalu Delete satu-satu.
        // (Batch delete bypass context, jadi UI gak tau kalau ada yg kehapus kecuali di-merge paksa).
        
        context.performAndWait {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NetworkHistory")
            // Batch Delete
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try self.context.execute(deleteRequest) as? NSBatchDeleteResult
                let objectIDArray = result?.result as? [NSManagedObjectID]
                
                // Merge changes biar UI sadar
                let changes = [NSDeletedObjectsKey: objectIDArray ?? []]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.context])
            } catch {
                print("Delete failed: \(error)")
            }
        }
        
        self.currentSessionID = nil
    }
    
    func deleteItem(_ item: NetworkHistory) {
        context.performAndWait{
            self.context.delete(item)
            try? self.context.save()
        }
    }
    
    func getWiFiName() -> String { return getNetworkDetails().ssid }
    func getCurrentBSSID() -> String {
        return getNetworkDetails().bssid
    }
    
    private func getNetworkDetails() -> (ssid: String, bssid: String) {
#if os(macOS)
        if let interface = CWWiFiClient.shared().interface() {
            // Ambil data real. Kalau izin lokasi ditolak, ini bakal return nil.
            // Fallback ke "Unknown" dan "00:00"
            return (
                interface.ssid() ?? "Wired/Unknown",
                interface.bssid() ?? "00:00:00:00:00:00"
            )
        }
#endif
        // Fallback kalau gak ada hardware WiFi
        return ("Unknown Network", "-")
    }
}
