//
//  Untitled.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.3))
            
            Text("Riwayat Kosong")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Fitur pencatatan riwayat koneksi akan segera hadir.\nData lo aman, tenang aja.")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear) // Biar nyatu sama background split view
    }
}
