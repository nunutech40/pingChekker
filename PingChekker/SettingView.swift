//
//  SettingView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 20/03/25.
//

import SwiftUI

struct SettingView: View {
    
    @Binding var showSettings: Bool // Binding untuk menutup modal
    @State private var selectedTab: String? = "History"

    var body: some View {
        VStack {
            // HEADER DENGAN TOMBOL CLOSE
            HStack {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center) // Tengahkan judul
                
                Button(action: {
                    showSettings = false // Menutup SettingView
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
            .padding(.top, 10) // Jarak dari atas
            
            Divider() // Garis pemisah antara header & konten

            // NAVIGATIONSPLITVIEW UNTUK SIDEBAR
            NavigationSplitView {
                List(selection: $selectedTab) {
                    NavigationLink("History", value: "History")
                    NavigationLink("Network Info", value: "NetworkInfo")
                }
                .frame(minWidth: 150, maxWidth: 180) // Sidebar lebih ramping
                .listStyle(SidebarListStyle())
            } detail: {
                if let selectedTab = selectedTab {
                    switch selectedTab {
                    case "History":
                        HistoryCheckerView()
                    case "NetworkInfo":
                        NetworkInfoView()
                    default:
                        Text("Select a tab")
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("Select a tab")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(minWidth: 500, maxWidth: 700, minHeight: 350, maxHeight: 500) // Perbaiki ukuran
        .padding()
    }
}
