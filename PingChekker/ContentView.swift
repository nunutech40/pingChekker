//
//  ContentView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 16/03/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var pingChecker = PingStrengthChecker()
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pemantau Kecepetan Internetmu")
                .font(.title)
                .fontWeight(.bold)
            Text("Ping Checker Strength 1.0.0")
                .fontWeight(.bold)
            
            
            Text("Rata-rata Latensi: \(pingChecker.averageLatency)")
                .font(.system(size: 12, weight: .light))
            
            Text("\(pingChecker.categoryAveragePing.capitalized)")
                .font(.system(size: 12, weight: .medium))
            Text(pingChecker.statusMessage)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .padding()
            
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
}
