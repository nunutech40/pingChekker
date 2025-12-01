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
    let persistanceController = PresistanceController.shared
    
    var body: some Scene {
        
        // --- WINDOW UTAMA ---
        WindowGroup(id: "dashboard") {
            ContentView(viewModel: viewModel)
                .frame(width: 480, height: 220)
                .fixedSize()
            // Suntik local db
                .environment(\.managedObjectContext, persistanceController.container.viewContext)
            // CCTV Window Accessor
                .background(WindowAccessor { window in
                    if let window = window {
                        window.delegate = appDelegate
                        appDelegate.homeViewModel = viewModel
                    }
                })
                .onAppear() {
                    UpdateService.shared.checkForUpdates()
                }
#if os(macOS)
                .background(VisualEffect().ignoresSafeArea())
#endif
        }
#if os(macOS)
        .windowResizability(.contentSize)

        .windowStyle(.hiddenTitleBar)
        .commands { SidebarCommands() }
#endif
        
        // --- MENU BAR ICON ---
#if os(macOS)
        MenuBarExtra {
            // Gunakan LocalizedStringKey untuk teks dinamis
            // viewModel.categoryText isinya KEY (misal "ELITE"), jadi harus dibungkus LocalizedStringKey biar diterjemahin
            Text("Status: \(LocalizedStringKey(viewModel.categoryText))")
                .font(.headline)
            
            // "Latency:" (Key)
            Text("Latency: \(viewModel.latencyText)")
            
            // "Quality Score:" (Key)
            Text("Quality Score: \(viewModel.mosScore) / 5.0")
            
            Divider()
            
            Button("Open Dashboard") { // Key: "Open Dashboard"
                NSApp.activate(ignoringOtherApps: true)
            }
            
            Button("Quit") { // Key: "Quit"
                NSApplication.shared.terminate(nil)
            }
            
        } label: {
            let iconName = getMenuBarIcon(status: viewModel.categoryText)
            Image(systemName: iconName)
        }
#endif
        
        // --- SETTINGS WINDOW ---
#if os(macOS)
        Settings {
            SettingsView()
                .environment(\.managedObjectContext, persistanceController.container.viewContext)
        }
#endif
    }
    
    func getMenuBarIcon(status: String) -> String {
        // Status di sini adalah KEY ENGLISH UPPERCASE ("ELITE", "GOOD", dll)
        // Jadi kita harus lowercased() biar match switch case
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
