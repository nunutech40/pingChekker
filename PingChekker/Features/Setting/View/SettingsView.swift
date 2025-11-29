//
//  SettingsView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 28/11/25.
//

import SwiftUI

// MARK: - 1. Data Model (Navigation Item)
enum SettingsPanel: String, CaseIterable, Identifiable {
    case about = "About"
    case host = "Custom Host"
    case history = "Network History"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .about: return "info.circle.fill"
        case .host: return "network"
        case .history: return "clock.arrow.circlepath"
        }
    }
}

// MARK: - 2. Main Container
struct SettingsView: View {
    
    @State private var selectedPanel: SettingsPanel? = .about
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        // Ukuran Window optimal untuk Split View
        .frame(width: 650, height: 400)
    }
}

// MARK: - 3. Molecular Abstractions (View Components)
private extension SettingsView {
    
    // Molekul 1: Sidebar Navigasi
    var sidebarContent: some View {
        List(selection: $selectedPanel) {
            
            Section(header: Text("Information")) {
                navLink(for: .about)
            }
            
            Section(header: Text("Configuration")) {
                navLink(for: .host)
                navLink(for: .history)
            }
        }
        .navigationTitle("Settings")
        #if os(macOS)
        .listStyle(.sidebar)
        #endif
    }
    
    // Molekul 2: Logika Routing Konten
    @ViewBuilder
    var detailContent: some View {
        if let panel = selectedPanel {
            switch panel {
            case .about:
                AboutView()
            case .host:
                HostSettingsView()
            case .history:
                HistoryView()
            }
        } else {
            ContentUnavailableView("Select an item", systemImage: "sidebar.left")
        }
    }
    
    // Molekul 3: Helper untuk Row Sidebar (Biar gak repetitif)
    func navLink(for panel: SettingsPanel) -> some View {
        NavigationLink(value: panel) {
            Label(panel.rawValue, systemImage: panel.iconName)
        }
    }
}
