//
//  HomeView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - ViewModel
    // Menggunakan @StateObject karena View ini yang "memiliki" dan meng-init ViewModel pertama kali.
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                // --- 1. Header ---
                VStack(spacing: 8) {
                    Text("Monitor Koneksi")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Ping Strength Checker")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                Spacer()

                // --- 2. Indikator Utama (Speedometer) ---
                VStack(spacing: 10) {
                    // Teks Latency (misal: "45 ms")
                    Text(viewModel.latencyText)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    // Speedometer Visual
                    // Kita perlu parsing string "45 ms" jadi Double "45.0"
                    SpeedometerView(
                        pingValue: parseLatency(viewModel.latencyText),
                        statusColor: viewModel.statusColor
                    )
                    .frame(width: 220, height: 130)
                }

                // --- 3. Status Category (Elite/Lag) ---
                Text(viewModel.categoryText.uppercased())
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(viewModel.statusColor)
                    // Animasi smooth saat warna berubah
                    .animation(.easeInOut, value: viewModel.statusColor)
                
                // --- 4. Status Message Box ---
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.statusColor.opacity(0.15)) // Background transparan
                    
                    Text(viewModel.statusMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true) // Box mengikuti tinggi teks
                .padding(.horizontal, 24)
                .animation(.easeInOut, value: viewModel.statusMessage)

                Spacer()
                
                // Footer (Opsional)
                Text("Realtime Monitoring")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Methods
    
    // Fungsi untuk mengubah string "45 ms" menjadi Double 45.0
    // Agar bisa dibaca oleh SpeedometerView
    private func parseLatency(_ text: String) -> Double {
        let cleanText = text.replacingOccurrences(of: " ms", with: "")
        return Double(cleanText) ?? 0.0
    }
}

// Preview untuk mengetes tampilan
#Preview {
    HomeView()
}
