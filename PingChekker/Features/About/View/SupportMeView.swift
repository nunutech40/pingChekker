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
                    
                    Text("Support Indie Developer") // Key
                        .font(.title2.bold())
                    
                    Text("Hi, I'm Nunu, the sole developer behind PingChekker. I built this app out of passion for technology. Your support means the world to keep this app free, ad-free, and constantly evolving with new features. Every coffee you buy gives me the energy and motivation to keep creating!") // Key
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
                        Label("Treat on Saweria", systemImage: "sparkles")
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
                        Label("Treat on Buy Me a Coffee", systemImage: "mug.fill")
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
