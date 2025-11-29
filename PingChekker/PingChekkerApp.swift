//
//  PingChekkerApp.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 16/03/25.
//
import SwiftUI

@main
struct PingCheckerApp: App {
    
    @StateObject private var viewModel = HomeViewModel()

    var body: some Scene {
        
        // --- WINDOW UTAMA (Dashboard) ---
        WindowGroup {
            ContentView(viewModel: viewModel)
                // KONSISTENSI UKURAN:
                // Samain sama desain HomeView lo (480x220). Jangan 300, jadi melar kosong bawahnya.
                .frame(width: 480, height: 220)
                .fixedSize()
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
