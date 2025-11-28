//
//  SettingStore.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 28/11/25.
//

import SwiftUI

class SettingsStore: ObservableObject {
    // Singleton
    static let shared = SettingsStore()
    
    // Kita HAPUS pingInterval, cukup fokus ke Host saja
    @AppStorage("targetHost") var targetHost: String = "8.8.8.8"
    
    // Validasi input sederhana
    var isValidHost: Bool {
        !targetHost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
