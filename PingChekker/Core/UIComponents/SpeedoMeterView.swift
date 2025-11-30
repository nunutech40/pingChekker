//
//  SpeedoMeterView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 20/03/25.
//

import SwiftUI

struct SpeedometerView: View {
    
    // Input Data
    var pingValue: Double
    var statusColor: Color
    
    // Konfigurasi Visual
    private let trackWidth: CGFloat = 12
    private let maxPing: Double = 500 // Batas atas meteran (500ms)
    
    var body: some View {
        ZStack {
            // 1. Track Background (Abu-abu tipis)
            Circle()
                .trim(from: 0, to: 0.5) // Setengah lingkaran
                .stroke(Color.secondary.opacity(0.15), style: StrokeStyle(lineWidth: trackWidth, lineCap: .round))
                .rotationEffect(.degrees(180))
            
            // 2. Active Progress (Warna Status)
            Circle()
                .trim(from: 0, to: progressValue())
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [statusColor.opacity(0.6), statusColor]),
                        center: .center,
                        startAngle: .degrees(180),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: trackWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(180))
            // Animasi Spring biar jarumnya membal enak dilihat
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: pingValue)
            
            // 3. Dekorasi Titik-titik (Scale)
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 1, height: 8)
                    .offset(y: -40) // Jarak dari center
                    .rotationEffect(.degrees(Double(i) * 45 - 90))
            }
            .offset(y: 15) // Penyesuaian posisi titik
        }
        .frame(height: 100) // Tinggi Container
        .padding(.bottom, -50) // Potong ruang kosong bawah (karena circle aslinya bulat)
    }
    
    // Helper: Konversi Ping (0-500) ke Progress (0.0 - 0.5)
    // Kenapa 0.5? Karena kita cuma pake setengah lingkaran (Arc).
    private func progressValue() -> CGFloat {
        // Cap di 500ms biar gak bablas muter
        let cappedPing = min(pingValue, maxPing)
        
        // Rumus: (Ping / Max) * 0.5
        return CGFloat((cappedPing / maxPing) * 0.5)
    }
}

// Preview buat testing visual doang
#Preview {
    VStack(spacing: 40) {
        SpeedometerView(pingValue: 20, statusColor: .green)
        SpeedometerView(pingValue: 120, statusColor: .orange)
        SpeedometerView(pingValue: 600, statusColor: .purple)
    }
    .frame(width: 300, height: 400)
    .padding()
}
