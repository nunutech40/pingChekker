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
            // 1. Background Ambient Glow
            // Memberikan bias warna di background sesuai status (Merah/Hijau/dll)
            viewModel.statusColor
                .opacity(0.1)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: viewModel.statusColor)
            
            // 2. Main Content (Horizontal Layout)
            HStack(spacing: 0) {
                
                // --- KOLOM KIRI: VISUAL (SPEEDOMETER) ---
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
                
                // --- KOLOM KANAN: DETAIL STATUS & KUALITAS ---
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. Header Kecil
                    HStack(spacing: 6) {
                        Circle()
                            .fill(viewModel.statusColor)
                            .frame(width: 6, height: 6)
                            .shadow(color: viewModel.statusColor.opacity(0.6), radius: 3)
                        
                        Text("PING MONITOR")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Session Avg Kecil di pojok kanan atas (buat yang kepo)
                        Text(viewModel.sessionAvgText)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 15)
                    
                    Spacer()
                    
                    // 2. Status Besar (Latency Category)
                    // Ini menunjukkan "Kecepatan"
                    Text(viewModel.categoryText.uppercased())
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(viewModel.statusColor)
                        .shadow(color: viewModel.statusColor.opacity(0.2), radius: 4, x: 0, y: 2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .animation(.spring(), value: viewModel.categoryText)
                    
                    // Pesan Fun (Latency)
                    Text(viewModel.statusMessage)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.bottom, 12)
                    // PERBAIKAN DISINI: Menggunakan .easeInOut bukan .opacity
                        .animation(.easeInOut, value: viewModel.statusMessage)
                    
                    // 3. Network Health Card (Kualitas & Rekomendasi)
                    // Ini menunjukkan "Kestabilan" & Saran Aktivitas
                    VStack(alignment: .leading, spacing: 6) {
                        // Judul Kondisi (misal: "Sangat Stabil")
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.recommendationIcon)
                                .font(.system(size: 12, weight: .bold))
                            
                            Text(viewModel.connectionCondition)
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(viewModel.recommendationColor)
                        
                        // Isi Rekomendasi (Saran Teknis)
                        Text(viewModel.connectionRecommendation)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.primary.opacity(0.8))
                            .lineLimit(3) // Maksimal 3 baris
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(2)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                        // Background box ngikutin warna kondisi tapi transparant banget
                            .fill(viewModel.recommendationColor.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.recommendationColor.opacity(0.2), lineWidth: 1)
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
}

#Preview {
    HomeView()
        .frame(width: 480, height: 220)
}
