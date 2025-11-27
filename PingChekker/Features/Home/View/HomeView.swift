//
//  HomeView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            // 1. Background Ambient Glow (Subtle)
            // Memberikan bias warna di background sesuai status (Merah/Hijau/dll)
            viewModel.statusColor
                .opacity(0.1)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: viewModel.statusColor)
            
            // 2. Main Content (Horizontal Layout)
            HStack(spacing: 0) {
                
                // --- KOLOM KIRI: VISUAL (Speedometer) ---
                ZStack {
                    // Speedometer Visual
                    SpeedometerView(
                        pingValue: parseLatency(viewModel.latencyText),
                        statusColor: viewModel.statusColor
                    )
                    .frame(width: 130, height: 80)
                    .opacity(0.9)
                    
                    // Angka Besar di Tengah
                    VStack(spacing: -2) {
                        Text(parseLatencyString(viewModel.latencyText))
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                        
                        Text("ms")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .offset(y: 15) // Penyesuaian posisi di tengah gauge
                }
                .frame(width: 160) // Lebar area kiri fix
                .padding(.leading, 10)

                // Divider Halus (Pemisah Visual)
                Rectangle()
                    .fill(Color.primary.opacity(0.05))
                    .frame(width: 1)
                    .padding(.vertical, 30)
                
                // --- KOLOM KANAN: DETAIL STATUS ---
                VStack(alignment: .leading, spacing: 6) {
                    
                    // Header Kecil
                    HStack(spacing: 6) {
                        Circle()
                            .fill(viewModel.statusColor)
                            .frame(width: 6, height: 6)
                            .shadow(color: viewModel.statusColor.opacity(0.6), radius: 3)
                        
                        Text("PING MONITOR")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                    
                    Spacer()
                    
                    // Status Besar (ELITE / LAG)
                    Text(viewModel.categoryText.uppercased())
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(viewModel.statusColor)
                        .shadow(color: viewModel.statusColor.opacity(0.2), radius: 4, x: 0, y: 2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8) // Kecilin dikit kalau teks kepanjangan
                        .animation(.spring(), value: viewModel.categoryText)
                    
                    // Message Pill (Keterangan)
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: getIconForStatus(category: viewModel.categoryText))
                            .font(.system(size: 14))
                            .foregroundColor(viewModel.statusColor)
                            .padding(.top, 2)
                        
                        Text(viewModel.statusMessage)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary.opacity(0.85))
                            .lineLimit(3) // Maksimal 3 baris
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary.opacity(0.03)) // Background box sangat tipis
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                            )
                    )
                    
                    Spacer()
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
        }
        // Pastikan ukuran ini match dengan di App.swift (480x220)
        .frame(width: 480, height: 220)
        #if os(macOS)
        .background(.regularMaterial) // Efek kaca native macOS
        #endif
    }
    
    // MARK: - Helpers
    
    private func parseLatency(_ text: String) -> Double {
        let cleanText = text.replacingOccurrences(of: " ms", with: "")
        return Double(cleanText) ?? 0.0
    }
    
    private func parseLatencyString(_ text: String) -> String {
        return text.replacingOccurrences(of: " ms", with: "")
    }
    
    private func getIconForStatus(category: String) -> String {
        switch category.lowercased() {
        case "elite": return "bolt.fill"
        case "good": return "wifi"
        case "good enough": return "wifi"
        case "enough": return "exclamationmark.shield"
        case "slow": return "tortoise.fill"
        case "unplayable": return "xmark.octagon.fill"
        case "no connection": return "wifi.slash"
        case "calculating": return "hourglass"
        default: return "waveform"
        }
    }
}

#Preview {
    HomeView()
        .frame(width: 480, height: 220)
}
