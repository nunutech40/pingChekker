//
//  PingChekkerApp.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 16/03/25.
//

import SwiftUI

@main
struct PingCheckerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // KUNCI UTAMA 1:
                // Ubah jadi Landscape (Melebar ke samping)
                // Width 480, Height 220 sangat pas untuk widget horizontal
                .frame(width: 480, height: 220)
                
                // Mencegah konten melar
                .fixedSize()
                
                // Tambahan: Biar backgroundnya transparan/nyatu sama design kita
                #if os(macOS)
                .background(VisualEffect().ignoresSafeArea())
                #endif
        }
        // KUNCI UTAMA 2:
        // Settingan Window macOS Native
        #if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar) // Hilangkan bar atas biar clean
        #endif
    }
}

// Helper buat efek background kaca (Blur) di belakang window
#if os(macOS)
struct VisualEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow // Tembus ke wallpaper
        view.state = .active
        view.material = .underWindowBackground // Efek blur standar macOS
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
#endif
