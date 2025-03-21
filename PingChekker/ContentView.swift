//
//  ContentView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 16/03/25.
//

import SwiftUI
struct ContentView: View {
    
    @StateObject private var pingChecker = PingStrengthChecker()
    @State private var showSettings = false // Untuk menampilkan SettingView sebagai modal

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer() // Mendorong ikon ke kanan
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                            .font(.system(size: 18)) // Ukuran ikon disesuaikan
                            .foregroundColor(.primary) // Menyesuaikan warna dengan tema sistem
                            .padding(.trailing, 5) // Mengurangi padding kanan agar lebih pas
                    }
                    .help("Settings") // Tooltip saat dihover (macOS)
                }
                .padding(.top, 5)

                Text("Pemantau Kecepetan Internetmu")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Ping Checker Strength 1.0.0")
                    .fontWeight(.bold)

                Text("Rata-rata Latensi: \(pingChecker.averageLatency)")
                    .font(.system(size: 12, weight: .light))

                SpeedometerView(
                    pingValue: Double(pingChecker.averageLatency) ?? 0.0,
                    statusColor: pingChecker.statusColor
                )
                .frame(width: 150, height: 80)
                .padding(.top, 16)

                Text("\(pingChecker.categoryAveragePing.capitalized)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(pingChecker.statusColor)
                    .padding(.top, 16)

                // Status Message dalam RoundedRectangle
                RoundedRectangle(cornerRadius: 10)
                    .fill(pingChecker.statusColor.opacity(0.2)) // Background sesuai status
                    .frame(width: 400, height: 50)
                    .overlay(
                        Text(pingChecker.statusMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    )

                Spacer(minLength: 10)
            }
            .frame(minWidth: 350, minHeight: 200)
        }
        .sheet(isPresented: $showSettings) {
            SettingView(showSettings: $showSettings) // Memastikan bisa ditutup
        }
    }
}


#Preview {
    ContentView()
}
