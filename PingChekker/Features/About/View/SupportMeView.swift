//
//  SupportMe.swift
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
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.bounce, value: true)
                        .padding(.top, 20)
                    
                    Text("Fuel the Development") // Key
                        .font(.title2.bold())
                    
                    Text("PingChekker is an indie project built with passion. Your support helps keep the app ad-free and constantly updated with new features.") // Key
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
                VStack(spacing: 12) {
                    // GANTI URL DI BAWAH INI DENGAN LINK ASLI LO
                    
                    // Opsi 1: Global (Ko-fi / PayPal)
                    SupportButtonLink(
                        url: "https://ko-fi.com", // Ganti link
                        title: "Buy me a Coffee", // Key
                        subtitle: "International (Ko-fi / PayPal)", // Key
                        icon: "cup.and.saucer.fill",
                        color: .brown
                    )
                    
                    // Opsi 2: Lokal (Saweria / Trakteer)
                    SupportButtonLink(
                        url: "https://saweria.co", // Ganti link
                        title: "Treat me Cendol", // Key
                        subtitle: "Indonesia (Saweria / QRIS)", // Key
                        icon: "qrcode",
                        color: .green
                    )
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

// Komponen Tombol Support (Reusable)
struct SupportButtonLink: View {
    let url: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let icon: String
    let color: Color
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 16) {
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // External Link Arrow
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.primary.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle()) // Biar bisa diklik di area kosong
        }
        .buttonStyle(.plain)
        // Efek Hover biar kerasa interaktif
        .onHover { isHovering in
            if isHovering { NSCursor.pointingHand.push() }
            else { NSCursor.pop() }
        }
    }
}

#Preview {
    SupportMeView()
        .frame(width: 500, height: 400)
}
