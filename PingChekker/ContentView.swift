//
//  ContentView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 16/03/25.
//

import SwiftUI

struct ContentView: View {
    
    // 1. Terima ViewModel dari Parent (PingCheckerApp)
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        // Langsung memanggil HomeView
        HomeView(viewModel: viewModel)
        // Kita pertahankan frame minimum ini untuk support macOS
        // agar windownya tidak terlalu kecil saat dibuka di Mac
    }
}

#Preview {
    // Inject Mock ViewModel untuk Preview
    ContentView(viewModel: HomeViewModel())
}
