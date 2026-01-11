//
//  AboutView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//
import SwiftUI

struct AboutView: View {
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Icon App
                Image(systemName: "waveform.path.ecg.rectangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .symbolEffect(.pulse, isActive: true)
                    .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text(String(format: NSLocalizedString("PingChekker %@", comment: ""), appVersion))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Created by Nunu Nugraha")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.controlBackgroundColor)) // macOS friendly background
                .cornerRadius(10)
                .shadow(radius: 2)
                
                Text("Created out of frustration with unstable internet.\nRuthless latency & jitter monitoring.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                NavigationLink {
                    SupportMeView()
                } label: {
                    Text("Support Developer (Donate)")
                        .font(.headline)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain) // Penting buat macOS
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                Text("© 2025 Nunu Nugraha Logic Inc.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    AboutView()
}
