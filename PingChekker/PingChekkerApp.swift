//
//  PingChekkerApp.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 16/03/25.
//
import SwiftUI

@main
struct PingCheckerApp: App {
    
    // 1. Pasang AppDelegate (Satpam)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var viewModel = HomeViewModel()
    
    // Inisialisasi persistance controller -> LocalDB -> CoreData
    let persistanceController = PresistanceController.shared

    var body: some Scene {
        
        // --- WINDOW UTAMA (Dashboard) ---
        WindowGroup(id: "dashboard") {
            ContentView(viewModel: viewModel)
                // KONSISTENSI UKURAN:
                // Samain sama desain HomeView lo (480x220). Jangan 300, jadi melar kosong bawahnya.
                .frame(width: 480, height: 220)
                .fixedSize()
                
            // Suntik local db yg udah di init di atas ke app
                .environment(\.managedObjectContext, persistanceController.container.viewContext)
                .background(WindowAccessor { window in
                    if let window = window {
                        // Pasang Satpam (Delegate) ke Window ini
                        window.delegate = appDelegate
                        
                        // Kenalin ViewModel ke AppDelegate (buat save)
                        appDelegate.homeViewModel = viewModel
                        
                        print("✅ Window Delegate Attached Successfully!")
                    }
                })
                #if os(macOS)
                .background(VisualEffect().ignoresSafeArea())
                #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
        }
        #endif

        // --- MENU BAR ICON (Tetap) ---
        #if os(macOS)
        MenuBarExtra {
            Text("Status: \(viewModel.categoryText.uppercased())")
                .font(.headline)
            
            Text("Latency: \(viewModel.latencyText)")
            Text("Quality Score: \(viewModel.mosScore) / 5.0")
            
            Divider()
            
            Button("Open Dashboard") {
                NSApp.activate(ignoringOtherApps: true)
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            
        } label: {
            let iconName = getMenuBarIcon(status: viewModel.categoryText)
            Image(systemName: iconName)
        }
        #endif
        
        // --- SETTINGS WINDOW (FIXED) ---
        #if os(macOS)
        Settings {
            SettingsView()
                // HAPUS .frame(width: 350...) DI SINI!
                // HAPUS .background(...) DI SINI!
                // Biarkan SettingsView handle ukurannya sendiri dan pake style native.
                .environment(\.managedObjectContext, persistanceController.container.viewContext)
        }
        #endif
    }
    
    func getMenuBarIcon(status: String) -> String {
        switch status.lowercased() {
        case "elite": return "bolt.fill"
        case "good", "good enough", "stable", "perfect": return "wifi"
        case "no connection", "offline": return "wifi.slash"
        case "calculating": return "circle.dotted"
        case "unstable", "laggy", "critical": return "wifi.exclamationmark"
        default: return "waveform"
        }
    }
}

#if os(macOS)
struct VisualEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .underWindowBackground
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
#endif
