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
            Section(header: Text("Current Network")) { // Key: "Current Network"
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
                                .monospaced()
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
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
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 8)
                                
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
                    
                    // 3. DETAILS (GRID LENGKAP)
                    Group {
                        // 🔥 FIX: Pake Closure syntax buat LocalizedStringKey
                        // "EXCELLENT" -> "SEMPURNA (DEWA)"
                        LabeledContent("Signal Quality") {
                            Text(LocalizedStringKey(wifi.signalQuality))
                        }
                        
                        LabeledContent("Tx Rate", value: String(format: "%.0f Mbps", wifi.txRate))
                        LabeledContent("Standard", value: wifi.phyMode)
                        
                        Divider().padding(.vertical, 4)
                        
                        LabeledContent("Noise Level", value: "\(wifi.noise) dBm")
                        LabeledContent("Channel", value: "\(wifi.channel) (\(wifi.band))")
                        LabeledContent("Security", value: wifi.security)
                        
                        Divider().padding(.vertical, 4)
                        
                        LabeledContent("Interface", value: wifi.interfaceName)
                        LabeledContent("Local IP", value: wifi.ipAddress)
                            .textSelection(.enabled)
                    }
                    
                } else if let error = viewModel.errorMessage {
                    // ERROR STATE
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        // 🔥 PENTING: Bungkus error message dengan LocalizedStringKey
                        Text(LocalizedStringKey(error))
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                } else {
                    // LOADING
                    HStack {
                        Spacer()
                        ProgressView().scaleEffect(0.8)
                        Spacer()
                    }
                    .padding()
                }
            }
            
            Section {
                Button {
                    viewModel.refreshData()
                } label: {
                    Label("Refresh Data", systemImage: "arrow.clockwise") // Key
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { viewModel.startLiveUpdate() }
        .onDisappear { viewModel.stopLiveUpdate() }
    }
}

#Preview {
    WifiDetailView()
        .frame(width: 400, height: 500)
}
