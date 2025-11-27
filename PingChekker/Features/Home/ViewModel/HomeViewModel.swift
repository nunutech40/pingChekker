//
//  HomeViewModel.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    // Output ke view
    @Published var latencyText: String = "- ms"
    @Published var statusMessage: String = "Connecting..."
    @Published var statusColor: Color = .gray
    @Published var categoryText: String = "calculating"
    
    private let service = PingService.shared
    
    init() {
        setupBinding()
        service.startMonitoring()
    }
    
    func setupBinding() {
        // Listen update dari service
        service.onPingUpdate = { [weak self] latency in
            DispatchQueue.main.async {
                self?.processLatency(latency)
            }
        }
        
        service.onError = { [weak self] errorMsg in
            DispatchQueue.main.async {
                self?.statusMessage = errorMsg
                self?.statusColor = .gray
                self?.categoryText = "ERROR"
                self?.latencyText = "- ms" // Reset angka kalau error
            }
        }
    }
    private func processLatency(_ latency: Double) {
        self.latencyText = String(format: "%.0f ms", latency)
        // INPUT LANGSUNG HURUF KECIL SESUAI DICTIONARY
        switch latency {
        case 0..<21:
            categoryText = "elite"       // Match key: "elite"
            statusColor = .green
        case 21..<51:
            categoryText = "good"        // Match key: "good"
            statusColor = .green.opacity(0.8)
        case 51..<101:
            categoryText = "good enough" // Match key: "good enough"
            statusColor = .yellow
        case 101..<201:
            categoryText = "enough"      // Match key: "enough"
            statusColor = .orange
        case 201..<501:
            categoryText = "slow"        // Match key: "slow"
            statusColor = .red
        case 501...:
            categoryText = "unplayable"  // Match key: "unplayable"
            statusColor = .purple
        default:
            categoryText = "no connection"
            statusColor = .gray
        }
        
        self.updateStatusMessage()
    }
    
    private func updateStatusMessage() {
        self.statusMessage = PingMessages.getRandomMessage(for: categoryText)
    }
}
