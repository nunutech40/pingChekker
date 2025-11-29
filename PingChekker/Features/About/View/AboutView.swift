//
//  AboutView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Icon App (Gue pake SF Symbol biar aman)
            Image(systemName: "waveform.path.ecg.rectangle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)
                .foregroundColor(.blue)
                .symbolEffect(.pulse, isActive: true) // Animasi dikit biar gak kaku
            
            VStack(spacing: 4) {
                Text("PingChekker")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0 (Alpha)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
            }
            
            Divider()
                .padding(.vertical, 8)
                .frame(width: 200)
            
            Text("Dibuat karena frustrasi dengan internet yang labil.\nMonitoring latensi & jitter tanpa ampun.")
                .font(.system(size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Text("© 2025 Nunu Nugraha Logic Inc.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(40)
        .frame(minWidth: 300, minHeight: 300)
    }
}
