//
//  MOSCalculactor.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import Foundation


// ==========================================================================================
// MARK: - TEORI & DEFINISI MOS (MEAN OPINION SCORE)
// ==========================================================================================
//
// 1. APA ITU MOS?
//    MOS adalah standar metrik global (ITU-T P.800) untuk mengukur kualitas pengalaman
//    pengguna (Quality of Experience / QoE) dalam jaringan telekomunikasi.
//    Awalnya dibuat untuk VoIP (Voice over IP), tapi sekarang jadi standar de-facto
//    untuk mengukur kestabilan koneksi real-time (Gaming, Zoom, Streaming).
//
//    Skala MOS:
//    5.0 - Excellent (Sempurna, setara tatap muka)
//    4.0 - Good (Bagus, ada cacat tak terasa)
//    3.0 - Fair (Cukup, butuh konsentrasi sedikit)
//    2.0 - Poor (Buruk, putus-putus/kresek)
//    1.0 - Bad (Hancur, tidak bisa komunikasi)
//
// 2. KENAPA PAKE MOS? BUKAN CUMA PING?
//    Ping (Latency) hanya mengukur "kecepatan". Itu dimensi tunggal.
//    Internet cepat (20ms) tapi tidak stabil (Jitter 100ms) akan terasa "Laggy/Teleport" di game.
//    MOS menggabungkan TIGA variabel maut:
//    - Latency (Delay)
//    - Jitter (Variasi delay/kestabilan)
//    - Packet Loss (Data hilang)
//    Menjadi satu angka sederhana (1-5) yang merepresentasikan "Rasa" koneksi tersebut.
//
// 3. RUMUS & SUMBER (THE E-MODEL)
//    Kita menggunakan pendekatan matematis dari standar **ITU-T G.107 (E-Model)**.
//    Ini adalah rumus konversi R-Factor ke MOS.
//
//    Langkah Perhitungan:
//    A. Effective Latency = Latency + (2 * Jitter) + 10.0
//       (Jitter dikali 2 karena dampaknya pada buffer lebih fatal daripada latency konstan).
//
//    B. R-Value (Transmission Rating Factor)
//       Nilai dasar 93.2 dikurangi dampak effective latency.
//       - Jika latency < 160ms: Pengurangan linear ringan.
//       - Jika latency > 160ms: Pengurangan drastis (karena delay terasa mengganggu otak).
//
//    C. Packet Loss Penalty
//       R-Value dikurangi (Loss * 2.5). Kehilangan paket adalah dosa terbesar.
//
//    D. Konversi R-Value ke MOS
//       Menggunakan rumus polinomial standar untuk memetakan R (0-100) ke MOS (1-5).
// ==========================================================================================


// Struct ini pure function
// Input A -> Output B. Selalu sama. Gak butuh Internet. Gak butuh database

struct MOSCalculactor {
    
    /// Menghitung skor MOS berdasarkan parameter jaringan.
    /// - Parameters:
    ///   - latency: Rata-rata latency dalam milidetik (ms).
    ///   - jitter: Variasi kedatangan paket dalam milidetik (ms).
    ///   - packetLoss: Persentase paket yang hilang (0.0 - 100.0).
    /// - Returns: Skor MOS skala 1.0 sampai 5.0.
    static func calculate(latency: Double, jitter: Double, packetLoss: Double) -> Double {
        // Logika RTO (Disconnected)
        if latency == 0 && packetLoss >= 100 { return 1.0 }
        
        // 1. Hitung Latency Efektif
        // Jitter dikali 2 karena efeknya lebih merusak buffer daripada latency konstan.
        let effectiveLatency = latency + (jitter * 2) + 10.0
        var rValue: Double = 0.0
        
        // 2. Hitung R-Value (Transmission Rating Factor)
        if effectiveLatency < 160 {
            // Pengurangan linear jika latency masih wajar (<160ms)
            rValue = 93.2 - (effectiveLatency / 40.0)
        } else {
            // Pengurangan drastis jika latency tinggi (>160ms)
            rValue = 93.2 - ((effectiveLatency - 120.0) / 10.0)
        }
        
        // 3. Kurangi R-Value berdasarkan Packet Loss (Hukuman berat)
        rValue = rValue - (packetLoss * 2.5)
        
        // Clamp R-Value (0 - 100)
        rValue = max(0.0, min(100.0, rValue))
        
        // 4. Konversi R-Value ke MOS (Rumus Polinomial)
        var mos: Double = 1.0
        if rValue > 0 {
            mos = 1.0 + (0.035 * rValue) + (rValue * (rValue - 60.0) * (100.0 - rValue) * 0.000007)
        }
        
        // Cap hasil akhir di 1.0 - 5.0
        return max(1.0, min(5.0, mos))
    }
}
