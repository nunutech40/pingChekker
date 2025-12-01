//
//  Untitled.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    
    @StateObject private var viewModel = HistoryViewModel()
    
    @FetchRequest(
        entity: NetworkHistory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \NetworkHistory.timestamp, ascending: false)]
    ) var historyItems: FetchedResults<NetworkHistory>
    
    var body: some View {
        VStack {
            if historyItems.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(historyItems) { item in
                        historyRow(for: item)
                            // Context Menu (Klik Kanan)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.requestDelete(item: item)
                                } label: {
                                    Label("Delete This History", systemImage: "trash") // Key
                                }
                            }
                    }
                }
                .listStyle(.plain)
                
                // Footer
                HStack {
                    Text("\(historyItems.count) records")
                        .font(.caption).foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Clear All", role: .destructive) {
                        viewModel.requestClearAll()
                    }
                    .font(.caption).buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .navigationTitle("Network History")
        
        // --- ALERTS ---
        .alert("Monitoring Active", isPresented: $viewModel.showRunningAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please stop monitoring first before deleting history data.")
        }
        
        .alert("Delete This Item?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { viewModel.confirmDelete() }
        }
        
        .alert("Delete ALL History?", isPresented: $viewModel.showClearAllConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) { viewModel.confirmClearAll() }
        } message: {
            Text("This action will permanently delete all history logs. This cannot be undone.")
        }
    }
}

// MARK: - Subviews
private extension HistoryView {
    
    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.3))
            
            Text("No History")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Data will appear here after you finish a session\nor switch networks.")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func historyRow(for item: NetworkHistory) -> some View {
        let evaluation = viewModel.evaluateQuality(mos: item.mos)
        
        // 🔥 CEK APAKAH BARIS INI ADALAH SESI AKTIF?
        let isActive = viewModel.isActiveSession(item)
        
        return HStack(alignment: .center, spacing: 12) {
            
            // KOLOM KIRI: Info Jaringan
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Ikon berubah kalau aktif + Animasi
                    Image(systemName: isActive ? "waveform.path.ecg" : "wifi")
                        .font(.caption)
                        .foregroundColor(isActive ? .green : .blue)
                        .symbolEffect(.pulse, isActive: isActive) // Animasi Detak Jantung
                    
                    Text(item.networkName ?? "Unknown WiFi")
                        .font(.system(size: 14, weight: .semibold))
                    
                    // Badge ACTIVE
                    if isActive {
                        Text("ACTIVE")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.green))
                    }
                }
                
                Text("Target: \(item.host ?? "-")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(viewModel.getFormattedDate(item.timestamp))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // KOLOM KANAN: Statistik
            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(Int(item.latency))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("ms")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 1, height: 25)
                
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: evaluation.icon)
                        .font(.system(size: 14))
                        .foregroundColor(evaluation.color)
                    
                    Text(String(format: "%.1f", item.mos))
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(evaluation.color)
                    
                    Text(evaluation.status)
                        .font(.system(size: 8, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundColor(evaluation.color.opacity(0.8))
                }
                .frame(width: 50)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        // Highlight background kalau aktif
        .background(
            isActive ? Color.green.opacity(0.05) : Color.clear
        )
        .cornerRadius(8)
    }
}
