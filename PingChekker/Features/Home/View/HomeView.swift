//
//  HomeView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 27/11/25.
//
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
            // 1. Background Ambient
            viewModel.statusColor
                .opacity(0.05)
                .ignoresSafeArea()
            
            // 2. Main Content (Tetap di tengah)
            HStack(spacing: 0) {
                leftQualityColumn
                
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 20)
                
                rightLatencyColumn
            }
            
            // 3. Settings Button (LAYER KHUSUS POJOK KANAN ATAS)
            // Kita pake VStack+HStack+Spacer manual biar bisa dikasih .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer() // Dorong ke kanan
                    settingsButton
                        .padding([.top, .trailing], 10) // Padding manual dari ujung layar
                }
                Spacer() // Dorong ke atas
            }
            // 🔥 INI KUNCINYA: Biar nembus ke area Title Bar
            .ignoresSafeArea()
        }
        .frame(width: 480, height: 220)
        #if os(macOS)
        .background(.regularMaterial)
        #endif
    }
}

// MARK: - View Components
private extension HomeView {
    
    // Tombol Gear
    var settingsButton: some View {
        SettingsLink {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.5))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Hapus padding di sini, pindah ke container di atas biar presisi
        .help("Open Settings (Cmd+,)")
    }
    
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
    
    // --- KOLOM KANAN (TETAP SAMA) ---
    var rightLatencyColumn: some View {
        VStack(spacing: 0) {
            
            // Header
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
            
            // Speedometer Centered
            ZStack {
                SpeedometerView(
                    pingValue: parseLatency(viewModel.latencyText),
                    statusColor: viewModel.statusColor
                )
                .frame(width: 140, height: 85)
                .opacity(0.9)
                
                VStack(spacing: 2) {
                    // BARIS 1: Angka + Unit (ms)
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(parseLatencyString(viewModel.latencyText))
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                        
                        Text("ms")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // BARIS 2: Badge Status
                    Text(viewModel.categoryText.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(viewModel.statusColor))
                }
                .offset(y: 10)
            }
            .padding(.bottom, 10)
            
            Spacer()
            
            // Fun Message Bubble
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
        return Double(text.replacingOccurrences(of: " ms", with: "")) ?? 0.0
    }
    
    func parseLatencyString(_ text: String) -> String {
        return text.replacingOccurrences(of: " ms", with: "")
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
        .frame(width: 480, height: 220)
}
