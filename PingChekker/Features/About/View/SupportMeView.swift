//
//  SupportMeView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import SwiftUI

struct SupportMeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // 1. Hero Section
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                        .shadow(radius: 5)
                        .padding(.top, 20)
                    
                    Text("Dukung Developer Indie") // Key
                        .font(.title2.bold())
                    
                    Text("Hai, saya Nunu, developer tunggal di balik PingChekker. Aplikasi ini saya buat dari passion untuk teknologi. Dukungan Anda sangat berarti untuk menjaga aplikasi ini tetap gratis, bebas iklan, dan terus berkembang dengan fitur-fitur baru. Setiap traktiran kopi dari Anda memberi saya energi dan motivasi untuk terus berkarya!") // Key
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: 400)
                        .lineSpacing(4)
                }
                
                Divider()
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                
                // 2. Donation Options
                VStack(spacing: 15) {
                    // Opsi 1: Saweria
                    Link(destination: URL(string: "https://saweria.co/nunugraha17")!) {
                        Label("Traktir di Saweria", systemImage: "sparkles")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: .orange.opacity(0.4), radius: 5, y: 2)
                    }
                    .buttonStyle(.plain)
                    
                    // Opsi 2: Buy Me a Coffee
                    Link(destination: URL(string: "https://www.buymeacoffee.com/nunutech401")!) {
                        Label("Traktir di Buy Me a Coffee", systemImage: "mug.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(color: .yellow.opacity(0.4), radius: 5, y: 2)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: 350)
                
                Spacer()
                
                // 3. Footer
                Text("Thank you for being awesome! ❤️") // Key
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }
}

#Preview {
    SupportMeView()
        .frame(width: 500, height: 500)
}
