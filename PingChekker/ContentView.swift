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
            Text("Ping Strength Checker")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Rata-rata Latensi: \(pingChecker.averageLatency)")
                .font(.headline)
            
            Text(pingChecker.statusMessage)
                .font(.body)
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
