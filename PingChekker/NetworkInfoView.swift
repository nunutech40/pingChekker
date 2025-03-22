//
//  NetworkInfoView.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 20/03/25.
//

import SwiftUI

struct NetworkInfoView: View {
    @StateObject private var wifiInfo = WifiInfo()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Informasi Jaringan")
                .font(.title2)
                .bold()
                .padding(.bottom, 10)

            Group {
                infoRow(title: "SSID", value: wifiInfo.wifiDetails.ssid)
                infoRow(title: "BSSID", value: wifiInfo.wifiDetails.bssid)
                infoRow(title: "IP Address", value: wifiInfo.wifiDetails.ipAddress)
                infoRow(title: "Subnet Mask", value: wifiInfo.wifiDetails.subnetMask)
                infoRow(title: "Gateway", value: wifiInfo.wifiDetails.defaultGateway)
                infoRow(title: "DNS", value: wifiInfo.wifiDetails.dnsServer)
                infoRow(title: "Signal Strength", value: wifiInfo.wifiDetails.signalStrength)
                infoRow(title: "Noise Level", value: wifiInfo.wifiDetails.noiseLevel)
                infoRow(title: "Channel", value: wifiInfo.wifiDetails.channel)
                infoRow(title: "Band", value: wifiInfo.wifiDetails.band)
                infoRow(title: "Tx Rate", value: wifiInfo.wifiDetails.txRate)
                infoRow(title: "MCS Index", value: wifiInfo.wifiDetails.mcsIndex)
                infoRow(title: "Country Code", value: wifiInfo.wifiDetails.countryCode)
                infoRow(title: "Security Type", value: wifiInfo.wifiDetails.securityType)
                infoRow(title: "IPv4 Routing Table", value: wifiInfo.wifiDetails.ipv4RoutingTable)
            }


            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title + ":")
                .bold()
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    NetworkInfoView()
}
