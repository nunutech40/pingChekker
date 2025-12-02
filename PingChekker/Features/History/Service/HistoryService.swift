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
        
        // --- 1. DEFINISIKAN PREDICATE KETAT SEBAGAI DEFAULT ---
        // Default: Host + BSSID + SSID (Logika awal Anda untuk jaringan stabil)
        var predicate = NSPredicate(
            format: "host == %@ AND bssid == %@ AND networkName == %@",
            host,
            netInfo.bssid,
            netInfo.ssid
        )
        
        // --- 2. KONDISI PELONGGARAN BSSID ---
        // Cek apakah ini Hotspot Pribadi (iPhone) atau jaringan Wired/Unknown.
        // Hotspot/iPhone: BSSID-nya sering rotasi (berubah).
        // Wired/Unknown: BSSID tidak valid ("-" atau "00:00:00...").
        let isLikelyUnstableBSSID: Bool = {
            let ssid = netInfo.ssid.localizedCaseInsensitiveContains("iphone") ||
            netInfo.ssid.localizedCaseInsensitiveContains("hotspot")
            
            let bssidInvalid = netInfo.bssid == "-" || netInfo.bssid.prefix(2) == "00"
            
            return ssid || bssidInvalid
        }()
        
        if isLikelyUnstableBSSID {
            // Jika BSSID tidak stabil: HANYA CEK HOST + SSID.
            // Ini akan memastikan sesi Hotspot/Wired berlanjut sebagai SATU entri,
            // meskipun BSSID-nya berubah setiap saat.
            predicate = NSPredicate(
                format: "host == %@ AND networkName == %@",
                host,
                netInfo.ssid
            )
        }
        
        // --- 3. EKSEKUSI PENCARIAN ---
        context.performAndWait {
            let request: NSFetchRequest<NetworkHistory> = NetworkHistory.fetchRequest()
            request.predicate = predicate // Menggunakan predicate yang sudah dipilih
            request.fetchLimit = 1
            
            do {
                let results = try context.fetch(request)
                
                if let existingLog = results.first {
                    // Router SAMA (Lanjut Sesi / Resume)
                    existingLog.timestamp = Date()
                    existingLog.status = "Monitoring..."
                    activeID = existingLog.id
                } else {
                    // Router BEDA (Bikin Baru)
                    let newLog = NetworkHistory(context: context)
                    activeID = UUID()
                    newLog.id = activeID
                    newLog.timestamp = Date()
                    newLog.host = host
                    newLog.networkName = netInfo.ssid
                    newLog.bssid = netInfo.bssid // Simpan BSSID yang ada (meskipun rotasi)
                    newLog.latency = 0.0
                    newLog.mos = 0.0
                    newLog.status = "Monitoring..."
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
