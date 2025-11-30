//
//  WifiDetailView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import SwiftUI

struct WifiDetailView: View {
    
    @StateObject private var viewModel = WifiDetailViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Current Network")) { // Key English
                if let wifi = viewModel.wifiInfo {
                    
                    // 1. HEADER (SSID & BSSID)
                    HStack {
                        Image(systemName: "wifi")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                            .padding(.trailing, 8)
                        
                        VStack(alignment: .leading) {
                            Text(wifi.ssid)
                                .font(.headline)
                            Text(wifi.bssid)
                                .font(.caption)
                                .monospaced() // Font coding buat MAC Address
                                .foregroundColor(.secondary)
                                .textSelection(.enabled) // Biar bisa dicopy
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // 2. SIGNAL STRENGTH (VISUAL BAR)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Signal Strength (RSSI)") // Key
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(wifi.rssi) dBm")
                                .font(.callout)
                                .bold()
                                .foregroundColor(viewModel.getSignalColor(wifi.rssi))
                        }
                        
                        // Logic Bar Sinyal
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Background Track
                                Capsule()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 8)
                                
                                // Active Bar
                                // Normalisasi RSSI (-100 sampe -30) jadi (0.0 sampe 1.0)
                                // -100 dBm = 0% (Mati)
                                // -30 dBm = 100% (Sempurna)
                                let percent = max(0, min(1.0, Double(100 + wifi.rssi) / 70.0))
                                
                                Capsule()
                                    .fill(viewModel.getSignalColor(wifi.rssi))
                                    .frame(width: geo.size.width * CGFloat(percent), height: 8)
                                    .animation(.default, value: wifi.rssi)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // 3. TECHNICAL DETAILS (GRID)
                    Group {
                        LabeledContent("Signal Quality", value: wifi.signalQuality) // Key
                        LabeledContent("Noise Level", value: "\(wifi.noise) dBm") // Key
                        LabeledContent("Channel", value: "\(wifi.channel) (\(wifi.band))") // Key
                        LabeledContent("Security", value: wifi.security) // Key
                    }
                    
                } else if let error = viewModel.errorMessage {
                    // ERROR STATE
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                } else {
                    // LOADING STATE
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                        Spacer()
                    }
                    .padding()
                }
            }
            
            // BUTTON REFRESH MANUAL
            Section {
                Button {
                    viewModel.refreshData()
                } label: {
                    Label("Refresh Data", systemImage: "arrow.clockwise") // Key
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            viewModel.startLiveUpdate()
        }
        .onDisappear {
            viewModel.stopLiveUpdate()
        }
    }
}

#Preview {
    WifiDetailView()
        .frame(width: 400, height: 500)
}
