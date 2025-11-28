//
//  SettingsView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 28/11/25.
//

import SwiftUI

struct SettingsView: View {
    
    // Menggunakan Store yang sudah kamu buat
    @StateObject private var store = SettingsStore.shared
    
    // State lokal untuk menampung inputan sementara
    @State private var hostInput: String = ""
    
    // Environment untuk menutup window (jika diperlukan)
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background Ambient (Netral)
            Color.blue.opacity(0.03)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // --- HEADER ---
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("KONFIGURASI")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // --- INPUT SECTION ---
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Host (IP / Domain)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary.opacity(0.8))
                    
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        
                        TextField("cth. 1.1.1.1 atau google.com", text: $hostInput)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, design: .monospaced))
                            .disableAutocorrection(true)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primary.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    )
                    
                    Text("Default: 8.8.8.8 (Google DNS). Kosongkan untuk reset.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .opacity(0.5)
                
                // --- ACTION BUTTON ---
                HStack {
                    Spacer()
                    
                    // Tombol Apply
                    Button(action: saveSettings) {
                        Text("Simpan Perubahan")
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    // Disable jika input kosong atau sama dengan yang sedang aktif
                    .disabled(hostInput.isEmpty || hostInput == store.targetHost)
                }
            }
            .padding(24)
        }
        // Ukuran Window Settings yang Compact
        .frame(width: 350, height: 220)
        #if os(macOS)
        .background(.regularMaterial) // Efek kaca native
        #endif
        .onAppear {
            // Isi textfield dengan IP yang sedang aktif saat dibuka
            hostInput = store.targetHost
        }
    }
    
    private func saveSettings() {
        let cleanHost = hostInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validasi simpel
        guard !cleanHost.isEmpty else { return }
        
        // 1. Simpan ke Memory Permanen (SettingsStore)
        store.targetHost = cleanHost
        
        // 2. Restart PingService dengan Host Baru
        // Pastikan PingService kamu punya fungsi updateHost yang sudah kita buat sebelumnya
        PingService.shared.updateHost(newHost: cleanHost)
        
        print("Settings Saved: Host changed to \(cleanHost)")
        
        // Opsional: Tutup window settings setelah save
        // dismiss()
    }
}

#Preview {
    SettingsView()
}
