//
//  ContentView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 16/03/25.
//

import SwiftUI

struct ContentView: View {
    // Tidak perlu @StateObject di sini lagi
    // Tidak perlu @State showSettings lagi
    
    var body: some View {
        // Langsung memanggil HomeView
        HomeView()
        // Kita pertahankan frame minimum ini untuk support macOS
        // agar windownya tidak terlalu kecil saat dibuka di Mac
            .frame(width: 300, height: 380)
    }
}

#Preview {
    ContentView()
}
