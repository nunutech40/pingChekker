//
//  SpeedoMeterView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 20/03/25.
//

import SwiftUI

struct SpeedometerView: View {
    var pingValue: Double // Nilai latency dalam ms
    var statusColor: Color
    
    var body: some View {
        ZStack {
            // Setengah Lingkaran Speedometer
            ArcShape()
                .stroke(statusColor, lineWidth: 10)
                .frame(width: 150, height: 75)
            
            // Jarum Penunjuk
            Rectangle()
                .fill(statusColor)
                .frame(width: 3, height: 40)
                .offset(y: -20) // Pusat jarum
                .rotationEffect(.degrees(angleForPing(pingValue)), anchor: .bottom)
        }
    }
    
    // Fungsi untuk menghitung sudut jarum berdasarkan ping
    private func angleForPing(_ ping: Double) -> Double {
        let minPing = 0.0
        let maxPing = 600.0 // Batas maksimum "Unplayable"
        let normalized = min(max((ping - minPing) / (maxPing - minPing), 0), 1)
        return (normalized * 180) - 90 // Sudut antara -90° sampai 90°
    }
}

// Bentuk Arc (Setengah Lingkaran)
struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
                    radius: rect.width / 2,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false)
        return path
    }
}

