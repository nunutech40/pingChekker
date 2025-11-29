//
//  SettingsView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 28/11/25.
//

import SwiftUI

enum SettingsPanel: String, CaseIterable, Identifiable {
    case about = "About"
    case host = "Custom Host"
    case history = "Network History"
    
    var id: String { self.rawValue }
    
    // Icon SF Symbols biar cantik
    var iconName: String {
        switch self {
        case .about: return "info.circle.fill"
        case .host: return "network"
        case .history: return "clock.arrow.circlepath"
        }
    }
}

struct SettingsView: View {
    
    // Default pilihan menu pertama kali buka
    @State private var selectedPanel: SettingsPanel? = .about
    
    var body: some View {
        NavigationSplitView {
            // --- SIDEBAR (MENU KIRI) ---
            List(selection: $selectedPanel) {
                
                Section(header: Text("Information")) {
                    NavigationLink(value: SettingsPanel.about) {
                        Label(SettingsPanel.about.rawValue, systemImage: SettingsPanel.about.iconName)
                    }
                }
                
                Section(header: Text("Configuration")) {
                    NavigationLink(value: SettingsPanel.host) {
                        Label(SettingsPanel.host.rawValue, systemImage: SettingsPanel.host.iconName)
                    }
                    
                    NavigationLink(value: SettingsPanel.history) {
                        Label(SettingsPanel.history.rawValue, systemImage: SettingsPanel.history.iconName)
                    }
                }
            }
            .navigationTitle("Settings")
            #if os(macOS)
            .listStyle(.sidebar) // Gaya sidebar native macOS
            #endif
            
        } detail: {
            // --- DETAIL AREA (KANAN) ---
            if let panel = selectedPanel {
                switch panel {
                case .about:
                    AboutView()
                case .host:
                    HostSettingsView() // Ini codingan lama lo
                case .history:
                    HistoryView()
                }
            } else {
                Text("Select an item")
                    .foregroundColor(.secondary)
            }
        }
        // Ukuran Window lebih lebar karena ada sidebar
        .frame(width: 700, height: 350)
    }
}
