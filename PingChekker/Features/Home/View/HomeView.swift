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
            backgroundGlow
            
            HStack(spacing: 0) {
                leftSpeedometerColumn
                dividerView
                rightDetailsColumn
            }
        }
        // Settingan Window Fix (Ukuran Widget Horizontal)
        .frame(width: 480, height: 220)
        #if os(macOS)
        .background(.regularMaterial) // Efek kaca native macOS
        #endif
    }
}

// MARK: - View Components (Abstraction)
// Memisahkan setiap bagian UI agar 'body' tetap bersih dan mudah dibaca
private extension HomeView {
    
    // 1. Background Ambient
    var backgroundGlow: some View {
        viewModel.statusColor
            .opacity(0.1)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: viewModel.statusColor)
    }
    
    // 2. Kolom Kiri (Visual Speedometer)
    var leftSpeedometerColumn: some View {
        ZStack {
            SpeedometerView(
                pingValue: parseLatency(viewModel.latencyText),
                statusColor: viewModel.statusColor
            )
            .frame(width: 130, height: 80)
            .opacity(0.9)
            
            // Angka Besar di Tengah Gauge
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
            .offset(y: 15)
        }
        .frame(width: 160)
        .padding(.leading, 10)
    }
    
    // 3. Garis Pemisah
    var dividerView: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.05))
            .frame(width: 1)
            .padding(.vertical, 30)
    }
    
    // 4. Kolom Kanan (Detail Informasi)
    var rightDetailsColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            
            Spacer()
            
            statusSection
            
            networkHealthCard
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
    }
    
    // 4a. Header Kecil (Judul & Titik Indikator)
    var headerSection: some View {
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
            
            Text(viewModel.sessionAvgText)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .padding(.top, 4)
        .padding(.bottom, 15)
    }
    
    // 4b. Status Utama (ELITE/LAG & Fun Message)
    var statusSection: some View {
        Group {
            Text(viewModel.categoryText.uppercased())
                .font(.system(size: 26, weight: .black, design: .default))
                .foregroundColor(viewModel.statusColor)
                .shadow(color: viewModel.statusColor.opacity(0.2), radius: 4, x: 0, y: 2)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .animation(.spring(), value: viewModel.categoryText)
            
            Text(viewModel.statusMessage)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .padding(.bottom, 12)
                .animation(.easeInOut, value: viewModel.statusMessage)
        }
    }
    
    // 4c. Kartu Kesehatan Jaringan (Rekomendasi Teknis)
    var networkHealthCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Judul Kondisi
            HStack(spacing: 6) {
                Image(systemName: viewModel.recommendationIcon)
                    .font(.system(size: 12, weight: .bold))
                
                Text(viewModel.connectionCondition)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(viewModel.recommendationColor)
            
            // Isi Saran
            Text(viewModel.connectionRecommendation)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.primary.opacity(0.8))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.recommendationColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.recommendationColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Logic Helpers
private extension HomeView {
    func parseLatency(_ text: String) -> Double {
        let cleanText = text.replacingOccurrences(of: " ms", with: "")
        return Double(cleanText) ?? 0.0
    }
    
    func parseLatencyString(_ text: String) -> String {
        return text.replacingOccurrences(of: " ms", with: "")
    }
}

#Preview {
    HomeView()
        .frame(width: 480, height: 220)
}
