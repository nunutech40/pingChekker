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
    case support = "Support Us"
    case host = "Custom Host"
    case wifiDetail = "WiFi Details"
    case history = "Network History"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .about: return "info.circle.fill"
        case .support: return "heart.fill"
        case .host: return "network"
        case .wifiDetail: return "wifi"
        case .history: return "clock.arrow.circlepath"
        }
    }
}

// MARK: - 2. Main Container
struct SettingsView: View {
    
    @State private var selectedPanel: SettingsPanel? = .about
    
    @StateObject private var viewModel = SettingsViewModel()
    
    // Mantra pembuka window
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .frame(width: 650, height: 400)
    }
}

// MARK: - 3. Molecular Abstractions (View Components)
private extension SettingsView {
    
    // Molekul 1: Sidebar Navigasi
    var sidebarContent: some View {
        List(selection: $selectedPanel) {
            
            // MENU ACTION (RESUME)
            Section {
                Button {
                    // 1. Jalanin Logic Resume
                    viewModel.resumeMonitoring()
                    // 2. Buka Window Dashboard (Penting!)
                    openWindow(id: "dashboard")
                    
                } label: {
                    HStack {
                        Image(systemName: viewModel.isMonitoring ? "waveform.path.ecg" : "play.fill")
                        
                        // Teks berubah sesuai status
                        Text(viewModel.isMonitoring ? "Monitoring Active" : "Resume Monitoring")
                            .fontWeight(.semibold)
                    }
                    // Warna: Sekunder (Abu) kalau jalan, Hijau kalau mati
                    .foregroundColor(viewModel.isMonitoring ? .secondary : .green)
                }
                .buttonStyle(.plain)
                // Tombol MATI kalau monitoring JALAN
                .disabled(viewModel.isMonitoring)
            }
            
            Section(header: Text("Information")) {
                navLink(for: .about)
                navLink(for: .support)
            }
            
            Section(header: Text("Configuration")) {
                navLink(for: .host)
                navLink(for: .wifiDetail)
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
            case .support:
                SupportMeView()
            case .host:
                HostSettingsView()
            case .wifiDetail:
                WifiDetailView()
            case .history:
                HistoryView()
            }
        } else {
            ContentUnavailableView("Select an item", systemImage: "sidebar.left")
        }
    }
    
    // Molekul 3: Helper untuk Row Sidebar
    func navLink(for panel: SettingsPanel) -> some View {
        NavigationLink(value: panel) {
            Label(panel.rawValue, systemImage: panel.iconName)
        }
    }
}
