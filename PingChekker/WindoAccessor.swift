//
//  WindoAccessor.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
    // Callback buat ngirim Window ke luar
    let callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        // View transparan/kosong, cuma buat hook
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
