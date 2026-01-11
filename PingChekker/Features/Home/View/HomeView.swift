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
            
            // 2. Main Content
            HStack(spacing: 0) {
                leftQualityColumn
                
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 20)
                
                rightLatencyColumn
            }
            
            // 3. Settings Button (Pojok Kanan Atas)
            VStack {
                HStack(spacing: 12) {
                    Spacer()
                    
                    // Button Pause/Play
                    Button(action: {
                        withAnimation {
                            viewModel.toggleMonitoring()
                        }
                    }) {
                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.8))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(viewModel.isPaused ? "Resume Monitoring" : "Pause Monitoring")
                    
                    settingsButton
                        .padding(.trailing, 10)
                }
                .padding(.top, 10)
                
                Spacer()
            }
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
    
    var settingsButton: some View {
        SettingsLink {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.5))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Open Settings (Cmd+,)") // Key: "Open Settings (Cmd+,)"
    }
    
    // --- KOLOM KIRI (QUALITY) ---
    var leftQualityColumn: some View {
        VStack(spacing: 2) {
            Text("QUALITY") // Key: "QUALITY"
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
            
            // viewModel.qualityCondition sudah dilocalize di ViewModel (String(localized:...))
            Text(viewModel.qualityCondition)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(viewModel.qualityColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
            
            Spacer().frame(height: 10)
            
            Text(viewModel.sessionAvgText)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .frame(width: 140)
        .padding(.vertical, 20)
    }
    
    // --- KOLOM KANAN (LATENCY) ---
    var rightLatencyColumn: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Circle()
                    .fill(viewModel.statusColor)
                    .frame(width: 6, height: 6)
                    .shadow(color: viewModel.statusColor.opacity(0.6), radius: 3)
                
                Text("REALTIME LATENCY") // Key: "REALTIME LATENCY"
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if viewModel.isOffline {
                    Text("OFFLINE") // Key: "OFFLINE"
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
            
            // Speedometer Area
            ZStack {
                SpeedometerView(
                    pingValue: viewModel.currentLatency,
                    statusColor: viewModel.statusColor
                )
                .frame(width: 140, height: 85)
                .opacity(0.9)
                
                // Text Overlay
                VStack(spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(String(format: "%.0f", viewModel.currentLatency))
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                        
                        Text("ms") // Key: "ms"
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // 🔥 LOKALISASI DINAMIS (PENTING) 🔥
                    // "elite" -> "ELITE" -> LocalizedStringKey("ELITE") -> Cari di Catalog -> "SULTAN"
                    Text(LocalizedStringKey(viewModel.categoryText.uppercased()))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(viewModel.statusColor))
                        .frame(maxWidth: 100)
                }
                .offset(y: 10)
            }
            .padding(.bottom, 10)
            
            Spacer()
            
            // Message Bubble
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 14))
                    .foregroundColor(viewModel.statusColor)
                    .padding(.top, 2)
                
                // viewModel.statusMessage sudah dilocalize di PingMessages.swift
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
}

#Preview {
    HomeView(viewModel: HomeViewModel())
        .frame(width: 480, height: 220)
}
