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
                        // 🔥 GANTI SWIPE JADI CONTEXT MENU (KLIK KANAN)
                        // Ini lebih reliable di macOS
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.requestDelete(item: item)
                                } label: {
                                    Label("Hapus Riwayat Ini", systemImage: "trash")
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
                    
                    // 🔥 TOMBOL CLEAR ALL YANG BENAR
                    Button("Clear All", role: .destructive) {
                        viewModel.requestClearAll() // Panggil Request, JANGAN deleteAll langsung!
                    }
                    .font(.caption).buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .navigationTitle("Network History")
        
        // --- ALERT 1: LAGI JALAN ---
        .alert("Monitoring Sedang Aktif", isPresented: $viewModel.showRunningAlert) {
            Button("Oke", role: .cancel) { }
        } message: {
            Text("Stop dulu monitoringnya kalau mau hapus data. Biar gak crash.")
        }
        
        // --- ALERT 2: DELETE SATU ITEM ---
        .alert("Hapus Item Ini?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Batal", role: .cancel) { }
            Button("Hapus", role: .destructive) { viewModel.confirmDelete() }
        }
        
        // --- ALERT 3: CLEAR ALL (NUKLIR) ---
        .alert("Hapus SEMUA Riwayat?", isPresented: $viewModel.showClearAllConfirmation) {
            Button("Batal", role: .cancel) { }
            Button("Hapus Semua", role: .destructive) { viewModel.confirmClearAll() }
        } message: {
            Text("Tindakan ini akan menghapus seluruh database history. Tidak bisa di-undo.")
        }
    }
}

// MARK: - Subviews (Molekular)
private extension HistoryView {
    
    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.3))
            
            Text("Riwayat Kosong")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Data akan muncul setelah sesi berakhir\natau saat lo ganti jaringan.")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func historyRow(for item: NetworkHistory) -> some View {
        // Ambil hasil evaluasi MOS dari ViewModel
        let evaluation = viewModel.evaluateQuality(mos: item.mos)
        
        return HStack(alignment: .center, spacing: 12) {
            
            // KOLOM KIRI: Info Jaringan
            VStack(alignment: .leading, spacing: 4) {
                // Nama WiFi (Utama)
                HStack {
                    Image(systemName: "wifi")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(item.networkName ?? "Unknown WiFi")
                        .font(.system(size: 14, weight: .semibold))
                }
                
                // Host Target
                Text("Target: \(item.host ?? "-")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                // Tanggal (Format Request Lo)
                Text(viewModel.getFormattedDate(item.timestamp))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // KOLOM KANAN: Statistik (Latency & MOS)
            HStack(spacing: 12) {
                
                // Latency (Angka Besar)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(Int(item.latency))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("ms")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                
                // Divider Kecil
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 1, height: 25)
                
                // MOS Badge (Warna-warni)
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
                .frame(width: 50) // Fix width biar rapi
            }
        }
        .padding(.vertical, 4)
    }
}
