//
//  LocationManager.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 01/12/25.
//


import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override private init() {
        super.init()
        manager.delegate = self
    }
    
    // Fungsi buat minta izin (Panggil ini pas App start)
    func requestPermission() {
        // Cek status sekarang
        let status = manager.authorizationStatus
        
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // Callback dari sistem kalau status berubah
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}
