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
            Section(header: Text("Target Connection")) {
                TextField("IP Address / Domain", text: $hostInput)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                
                Text("Default: 8.8.8.8 (Google). Current: \(store.targetHost)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Button("Apply Changes") {
                    saveSettings()
                }
                .disabled(hostInput.isEmpty || hostInput == store.targetHost)
            }
        }
        .padding()
        .onAppear { hostInput = store.targetHost }
    }
    
    private func saveSettings() {
        let cleanHost = hostInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanHost.isEmpty else { return }
        
        store.targetHost = cleanHost
        PingService.shared.updateHost(newHost: cleanHost)
    }
}
