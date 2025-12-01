//
//  UpdateService.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 01/12/25.
//

import Foundation
import SwiftUI
import FirebaseRemoteConfig

class UpdateService: ObservableObject {
    
    // UBAH INI: Tidak lagi computed property, ini instance yang di-delay init-nya
    static let shared = UpdateService()
    
    // Buat private dan Optional/Lazy
    private var remoteConfig: RemoteConfig?
    
    // --- FORCE UPDATE / PAYWALL LOGIC ---
    @Published var showForceUpdate: Bool = false
    @Published var storeURL: URL?
    
    // FEATURE FLAGS (Pengaturan dari Jauh)
    @Published var showWifiDetails: Bool = false
    @Published var showSupportMenu: Bool = false
    
    private init() {
        // HAPUS SEMUA LOGIC INIT DARI SINI
        // Panggilan utama dilakukan di .onAppear App.swift, setelah setup
    }
    
    //FUNGSI INI DIPANGGIL OLEH APPDELEGATE SETELAH FIREBASE.CONFIGURE()
    func setupAndConfigure() {
        // Pastikan konfigurasi hanya terjadi sekali
        guard self.remoteConfig == nil else { return }
        
        self.remoteConfig = RemoteConfig.remoteConfig()
        setupDefaultValues()
        
        // Panggil check update untuk pertama kalinya
        // NOTE: Panggilan utama untuk fetch update akan dilakukan di .onAppear App.swift
    }
    
    private func setupDefaultValues() {
        let defaults: [String: NSObject] = [
            "min_version": "1.0.0" as NSObject,
            "store_url": "https://apps.apple.com/id/app/example" as NSObject,
            "force_update": false as NSObject,
            "show_wifi_detail": true as NSObject,
            "show_support_menu": true as NSObject
        ]
        self.remoteConfig?.setDefaults(defaults)
    }
    
    func checkForUpdates() {
        guard let rc = remoteConfig else {
            return
        }
        
        let fetchInterval: TimeInterval = 0 // 0 buat Debug
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = fetchInterval
        rc.configSettings = settings
        
        rc.fetch { [weak self] status, error in
            if status == .success {
                rc.activate { changed, error in
                    self?.readFeatureFlags()
                    self?.checkVersionLogic()
                }
            } else {
                // Kalau gagal fetch, kita tetap jalankan logic dengan nilai default yang sudah di-setup.
                self?.readFeatureFlags()
                self?.checkVersionLogic()
            }
        }
    }
    
    private func readFeatureFlags() {
        guard let rc = remoteConfig else { return }
        
        // Baca nilai dari Firebase dan update @Published properties
        DispatchQueue.main.async {
            self.showWifiDetails = rc["show_wifi_detail"].boolValue
            self.showSupportMenu = rc["show_support_menu"].boolValue
        }
    }
    
    private func checkVersionLogic() {
        guard let rc = remoteConfig else { return }
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let minVersion = rc["min_version"].stringValue ?? "1.0.0"
        let storeLink = rc["store_url"].stringValue ?? ""
        let forceUpdate = rc["force_update"].boolValue
        
        if forceUpdate || currentVersion.compare(minVersion, options: .numeric) == .orderedAscending {
            DispatchQueue.main.async {
                self.storeURL = URL(string: storeLink)
                self.showForceUpdate = true
            }
        }
    }
}
