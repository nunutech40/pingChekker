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
        
        // Pake perform (Main Queue)
        context.performAndWait {
            let request: NSFetchRequest<NetworkHistory> = NetworkHistory.fetchRequest()
            request.predicate = NSPredicate(format: "host == %@ AND networkName == %@", host, netInfo.ssid)
            request.fetchLimit = 1
            
            do {
                let results = try context.fetch(request)
                
                if let existingLog = results.first {
                    print("♻️ [HistoryService] Resuming session...")
                    existingLog.timestamp = Date()
                    existingLog.status = "Monitoring..."
                    activeID = existingLog.id
                } else {
                    print("✨ [HistoryService] Creating new session...")
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
                }
                
                // Save Main Context -> Langsung Update UI
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print("❌ [HistoryService] Init failed: \(error)")
            }
        }
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
                print("🏁 Session Finalized.")
            }
        }
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
                
                print("🗑 All history cleared.")
            } catch {
                print("❌ Delete failed: \(error)")
            }
        }
    }
    
    func deleteItem(_ item: NetworkHistory) {
        context.performAndWait{
            self.context.delete(item)
            try? self.context.save()
        }
    }
    
    func getWiFiName() -> String { return getNetworkDetails().ssid }
    
    private func getNetworkDetails() -> (ssid: String, bssid: String) {
        #if os(macOS)
        if let interface = CWWiFiClient.shared().interface() {
            return (interface.ssid() ?? "Wired/Unknown", interface.bssid() ?? "00:00")
        }
        #endif
        return ("Unknown Network", "-")
    }
}
