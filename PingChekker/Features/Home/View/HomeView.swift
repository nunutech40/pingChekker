//
//  HomeView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            // Background Ambient
            viewModel.statusColor
                .opacity(0.05)
                .ignoresSafeArea()
            
            HStack(spacing: 0) {
                // KIRI: KUALITAS JARINGAN (Quality/MOS)
                leftQualityColumn
                
                // DIVIDER
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 20)
                
                // KANAN: LATENCY (Speedometer & Pesan)
                rightLatencyColumn
            }
        }
        .frame(width: 480, height: 220)
        #if os(macOS)
        .background(.regularMaterial)
        #endif
    }
}

// MARK: - View Components
private extension HomeView {
    
    // --- KOLOM KIRI (TETAP SAMA) ---
    var leftQualityColumn: some View {
        VStack(spacing: 2) {
            Text("QUALITY")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            Image(systemName: viewModel.qualityIcon)
                .font(.system(size: 24))
                .foregroundColor(viewModel.qualityColor)
                .padding(.bottom, 4)
                .symbolEffect(.bounce, value: viewModel.qualityCondition)
            
            Text(viewModel.mosScore)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundColor(viewModel.qualityColor)
                .contentTransition(.numericText())
            
            Text(viewModel.qualityCondition)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(viewModel.qualityColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
            
            Spacer()
                .frame(height: 10)
            
            Text(viewModel.sessionAvgText)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .frame(width: 140)
        .padding(.vertical, 20)
    }
    
    // --- KOLOM KANAN (UPDATED LAYOUT) ---
    var rightLatencyColumn: some View {
        VStack(spacing: 0) {
            
            // 1. Header
            HStack {
                Circle()
                    .fill(viewModel.statusColor)
                    .frame(width: 6, height: 6)
                    .shadow(color: viewModel.statusColor.opacity(0.6), radius: 3)
                
                Text("REALTIME LATENCY")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if viewModel.isOffline {
                    Text("OFFLINE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.red))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            Spacer()
            
            // 2. SPEEDOMETER CENTERED (REVISI POSISI MS)
            ZStack {
                // Visual Gauge (Lengkungan)
                SpeedometerView(
                    pingValue: parseLatency(viewModel.latencyText),
                    statusColor: viewModel.statusColor
                )
                .frame(width: 140, height: 85)
                .opacity(0.9)
                
                // Angka & Unit (Overlay di tengah bawah)
                VStack(spacing: 4) { // Kasih jarak dikit antara Angka dan Badge
                    
                    // BARIS 1: Angka + Unit (Sebelahan)
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(parseLatencyString(viewModel.latencyText))
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                        
                        Text("ms")
                            .font(.system(size: 16, weight: .bold, design: .rounded)) // Ukuran proporsional
                            .foregroundColor(.secondary)
                    }
                    
                    // BARIS 2: Badge Status (Di Bawahnya)
                    Text(viewModel.categoryText.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(viewModel.statusColor))
                }
                .offset(y: 10) // Geser posisi biar pas di tengah lengkungan
            }
            .padding(.bottom, 10)
            
            Spacer()
            
            // 3. Fun Message Bubble
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 14))
                    .foregroundColor(viewModel.statusColor)
                    .padding(.top, 2)
                
                Text(viewModel.statusMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Helpers
    func parseLatency(_ text: String) -> Double {
        let cleanText = text.replacingOccurrences(of: " ms", with: "")
        return Double(cleanText) ?? 0.0
    }
    
    func parseLatencyString(_ text: String) -> String {
        return text.replacingOccurrences(of: " ms", with: "")
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
        .frame(width: 480, height: 220)
}
