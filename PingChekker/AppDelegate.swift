//
//  AppDelegate.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    var homeViewModel: HomeViewModel?
    
    // 🔥 FLAG SAKTI: Penanda kalau user udah setuju keluar
    private var hasConfirmedQuit = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        LocationManager.shared.requestPermission()
    }
    
    // 1. Logic biar App mati kalau window ditutup
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // 2. Logic Klik X
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return askUserToQuit()
    }
    
    // 3. Logic Cmd+Q
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Cek dulu: Udah confirm belum di windowShouldClose?
        if hasConfirmedQuit {
            return .terminateNow
        }
        
        // Kalau belum (misal Cmd+Q tanpa klik X), tanya dulu
        if askUserToQuit() {
            return .terminateNow
        } else {
            return .terminateCancel
        }
    }
    
    // --- LOGIC POPUP ---
    private func askUserToQuit() -> Bool {
        // 🔥 CEK FLAG DULU: Kalau udah pernah bilang YES, loloskan langsung.
        if hasConfirmedQuit { return true }
        
        let alert = NSAlert()
        // GANTI JADI ENGLISH KEYS
        alert.messageText = "Stop Monitoring?"
        alert.informativeText = "The ping session will be saved to history before the application closes."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Save & Quit")
        alert.addButton(withTitle: "Cancel")
        
        // Supaya alert muncul sheet di window (lebih native)
        // Kalau nil, dia bakal muncul modal di tengah layar
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // === USER PILIH YES ===
            print("🛑 Quitting... Saving Session...")
            
            // 🔥 KUNCI FLAG BIAR GAK NANYA LAGI
            hasConfirmedQuit = true
            
            // Save Data
            homeViewModel?.forceStopSession()
            
            // Jeda 0.2 detik buat Core Data nulis
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
            
            return true
        } else {
            // === USER PILIH BATAL ===
            return false
        }
    }
}
