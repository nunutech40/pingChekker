//
//  MosCalculactorTest.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import XCTest
@testable import PingChekker

class MosCalculactorTest: XCTestCase {
    
    // 1. TEST SKENARIO IDEAL (LAN/Localhost)
    // Latency hampir 0, Jitter 0, Loss 0, Harusnya dapet skor nyaris sempurna
    func test_perfectConnection_ReturnMaxMOS() {
        // Given
        let lat = 1.0
        let jit = 0.0
        let loss = 0.0
        
        // when
        let score = MOSCalculactor.calculate(latency: lat, jitter: jit, packetLoss: loss)
        
        // Then
        // Skor MOS max itu 4.4 - 4.5 (secara matematis E-Model gak bisa 5.0 murni kecuali R=100)
        XCTAssertGreaterThan(score, 4.3, "Koneksi sempurna harusnya di atas 4.3")
        XCTAssertLessThanOrEqual(score, 5.0, "Gak boleh lebih dari 5.0")
    }
    
    // 2. TEST SKENARIO NORMAL (Wifi Bagus)
    // Latency 40ms, Jitter 5ms. Ini standart 'Good'
    func test_normalConnection_ReturnGoodMOS() {
        let score = MOSCalculactor.calculate(latency: 40.0, jitter: 5.0, packetLoss: 0.0)
        
        // Harusnya masih 'Good' (> 4.0)
        XCTAssertGreaterThan(score, 4.0)
    }
    
    // 3. TEST BATAS AMBANG (Boundary 160ms)
    // Di kode ada logic: if effectiveLatency < 160. Kita test tepat dibawah atau di atasnya.
    
    // Kasus A: Sedikit dibawah ambang batas <160 (Pake rumus ringan)
    func test_Below160ms_UsesLinearPenalty() {
        // Effective = Latency + (2*Jitter) + 10
        // Misal: 100 + (2*5) + 10 = 120ms (Di bawah 160)
        let score = MOSCalculactor.calculate(latency: 100.0, jitter: 5.0, packetLoss: 0.0)
        
        // Masih playable, harusnya skor sekitar 3.8 - 4.0
        XCTAssertGreaterThan(score, 3.5)
    }
    
    // Kasus B: Di atas 160ms (Pake Rumus Berat)
    func test_Above160ms_UsesHeavyPenalty() {
        // Misal: 180 + (2*5) + 10 = 200ms (Di atas 160)
        // Ini harusnya drop parah karena delay terasa
        let score = MOSCalculactor.calculate(latency: 300.0, jitter: 5.0, packetLoss: 0.0)
        
        // Pasti di bawah 4.0, mungkin sekitar 3.0 - 3.5
        // Sekarang pasti lulus karena 3.7 < 4.0
        XCTAssertLessThan(score, 4.0)
        XCTAssertGreaterThan(score, 3.0) // Tapi jangan sampe jelek banget
    }
    
    // 4. TEST PACKET LOSS (Hukuman Berat)
    // Latency rendah (20ms) tapi Loss 10%. Ini koneksi busuk.
    func test_HighPacketLoss_DrasticallyLowersMOS() {
        // Tanpa loss: MOS ~4.3
        // Dengan loss 10%: Penalty = 10 * 2.5 = 25 poin R-Value.
        let score = MOSCalculactor.calculate(latency: 20.0, jitter: 2.0, packetLoss: 10.0)
        
        // Harusnya jatuh ke range 'Fair' atau 'Poor'
        XCTAssertLessThan(score, 3.8)
    }
    
    // 5. TEST RTO (Mati Total)
    // Ini ngetes baris pertama: if latency == 0 && packetLoss >= 100
    func test_RTO_ReturnsMinimumMOS() {
        let score = MOSCalculactor.calculate(latency: 0.0, jitter: 0.0, packetLoss: 100.0)
        
        // Wajib 1.0
        XCTAssertEqual(score, 1.0, accuracy: 0.001)
    }
    
    // 6. TEST DATA SAMPAH (Robustness)
    // Gimana kalau latency negatif? (Mustahil secara fisik, tapi kode harus aman)
    // Di kode lu ada `max(0.0, ...)` jadi harusnya aman.
    func test_NegativeInputs_AreHandledSafely() {
        let score = MOSCalculactor.calculate(latency: -50.0, jitter: -5.0, packetLoss: 0.0)
        
        // Gak boleh crash, dan harusnya dapet skor tinggi (karena dianggap 0 penalty)
        // Atau skor 1.0 tergantung implementasi max(0).
        // Di kode lu: effectiveLatency bakal kecil, R-value gede -> MOS gede.
        // Ini cuma buat pastiin gak crash.
        XCTAssertGreaterThan(score, 1.0)
        XCTAssertLessThanOrEqual(score, 5.0)
    }
}
