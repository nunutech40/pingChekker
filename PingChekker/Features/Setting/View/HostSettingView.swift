//
//  HostSettingView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import SwiftUI

struct HostSettingsView: View {
    @StateObject private var store = SettingsStore.shared
    @State private var hostInput: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Target Connection")) { // Key: "Target Connection"
                TextField("IP Address / Domain", text: $hostInput) // Key: "IP Address / Domain"
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                
                // Interpolasi String (SwiftUI otomatis bikin key "Current: %@")
                Text("Current: \(store.targetHost)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Button("Apply Changes") { // Key: "Apply Changes"
                    saveSettings()
                }
                .disabled(hostInput.isEmpty || hostInput == store.targetHost)
            }
            
            Section(footer: Text("Default: 8.8.8.8 (Google DNS). Leave empty to reset.")) { // Key: "Default:..."
                EmptyView()
            }
        }
        .padding()
        .onAppear { hostInput = store.targetHost }
    }
    
    private func saveSettings() {
        let cleanHost = hostInput.trimmingCharacters(in: .whitespacesAndNewlines)
        // Kalau kosong, reset ke default (opsional logic)
        if cleanHost.isEmpty {
            store.targetHost = "8.8.8.8"
            PingService.shared.updateHost(newHost: "8.8.8.8")
            hostInput = "8.8.8.8"
            return
        }
        
        store.targetHost = cleanHost
        PingService.shared.updateHost(newHost: cleanHost)
    }
}
