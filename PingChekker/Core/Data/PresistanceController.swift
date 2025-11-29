//
//  PresistanceController.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import CoreData

struct PresistanceController {
    static let shared = PresistanceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // PENTING: Nama ini HARUS SAMA dengan nama file .xcdatamodeld
        self.container = NSPersistentContainer(name: "LocalDB")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Error here -> typo nama model or disk is full
                // For Production, ganti fatalError dg log yang bener
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Biar otomatis update UI kalau ada perubahan
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("CoreData Save Error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
