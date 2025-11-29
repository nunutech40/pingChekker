//
//  Notification+Ext.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 29/11/25.
//

import Foundation

extension Notification.Name {
    // Sinyal buat ngereset sesi ping dari jauh
    static let resetPingSession = Notification.Name("resetPingSession")
    static let startPingSession = Notification.Name("startPingSession")
    static let monitoringStateChanged = Notification.Name("monitoringStateChanged")
}
