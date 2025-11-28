//
//  PingServiceProtocol.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 28/11/25.
//

// =================================================================================
// MARK: - PROTOCOL DEFINITION (KONTRAK KERJA)
// =================================================================================
// Ini biar ViewModel gak terikat mati sama class PingService asli (Loose Coupling).
// Memudahkan testing pake Mock Data nanti.
protocol PingServiceProtocol {
    var onPingUpdate: ((PingResult) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func startMonitoring()
    func stopMonitoring()
    func updateHost(newHost: String)
}
