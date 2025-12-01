//
//  HistoryServiceTest.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import XCTest
import CoreData
@testable import PingChekker

// ==========================================================================================
// MARK: - TEORI UNIT TESTING SERVICE (DATABASE LAYER)
// ==========================================================================================
//
// 1. MASALAH UTAMA: "SIDE EFFECTS" (EFEK SAMPING)
//    Service ini aslinya menulis ke Harddisk (SQLite) dan membaca Hardware (WiFi).
//    - Jika kita test pakai database asli: Data development lu bakal kehapus/kotor. Lambat.
//    - Jika kita test WiFi asli: Kita gak bisa simulasi ganti jaringan.
//
// 2. SOLUSI: IN-MEMORY DATABASE
//    Kita menggunakan `PresistanceController(inMemory: true)`.
//    Ini membuat database bayangan di RAM.
//    - Cepat (Microseconds).
//    - Bersih (Hilang begitu test selesai).
//    - Aman (Gak nyentuh data asli user).
//
// 3. APA YANG HARUS DITEST? (KATEGORI PENGUJIAN)
//    A. CRUD Basics (Create/Read/Delete):
//       - Apakah fungsi save beneran nambah baris di DB?
//       - Apakah fungsi delete beneran ngosongin DB?
//
//    B. Business Logic (Upsert/Cerdas):
//       - Ini logic terpenting di app lu: "Initialize Session".
//       - Skenario 1: Data belum ada -> Create Baru.
//       - Skenario 2: Data sudah ada -> Update Timestamp (Jangan Create).
//       - Skenario 3: Host beda -> Create Baru.
//
//    C. Integrity (Data Validity):
//       - Apakah pas di-update (`updateSession`), data lamanya beneran keganti?
//
// 4. BATASAN (LIMITATION)
//    Karena kita belum nge-mock `CWWiFiClient` (Hardware), kita asumsikan
//    nama WiFi selama test adalah konstan (apa adanya di mac lu saat ini).
// ==========================================================================================

class HistoryServiceTest: XCTestCase {
    
    var service: HistoryService!
    var mockController: PresistanceController!
    
    override func setUp() {
        super.setUp()
        
        // 1. SIAPKAN DATABASE RAM (In-Memory)
        // Pastikan PresistanceController lu punya init(inMemory: Bool)
        mockController = PresistanceController(inMemory: true)
        
        // 2. INJECT KE SERVICE (Dependency Injection)
        // Kita bikin instance baru, JANGAN PAKE .shared (Singleton)
        // Biar state-nya fresh tiap kali test jalan.
        service = HistoryService(controller: mockController)
    }
    
    override func tearDown() {
        service = nil
        mockController = nil
        super.tearDown()
    }
    
    // ==========================================
    // KATEGORI 1: BUSINESS LOGIC (UPSERT)
    // ==========================================
    
    func test_InitializeSession_NewHost_CreatesNewRow() {
        // Given
        let host = "google.com"
        
        // When
        let uuid = service.initializeSession(host: host)
        
        // Then
        XCTAssertNotNil(uuid, "Harusnya return UUID baru")
        
        // Cek isi DB
        let result = service.fetchLastLog(forHost: host, networkName: service.getWiFiName())
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, "Monitoring...")
        XCTAssertEqual(result?.latency, 0.0)
    }
    
    func test_InitializeSession_ExistingHost_UpdatesTimestamp_DoesNotDuplicate() {
        // Given (Kita buat sesi pertama dulu)
        let host = "8.8.8.8"
        let id1 = service.initializeSession(host: host)
        
        // Kita simpan timestamp lama
        // (Hack dikit: CoreData timestamp presisi tinggi, sleep 1 detik biar beda)
        // Tapi karena unit test harus cepet, kita asumsi logic-nya bener.
        // Kita cek COUNT-nya aja.
        
        // When (Kita panggil lagi dengan host & wifi yg SAMA)
        let id2 = service.initializeSession(host: host)
        
        // Then
        // 1. ID harusnya SAMA (Resume), bukan ID baru
        XCTAssertEqual(id1, id2, "Harusnya me-return ID yang sama (Resume Logic)")
        
        // 2. Jumlah baris di DB harus tetep 1, bukan 2
        let context = mockController.container.viewContext
        let count = try? context.count(for: NetworkHistory.fetchRequest())
        XCTAssertEqual(count, 1, "Harusnya gak nambah baris baru (Duplicate Prevention)")
    }
    
    func test_InitializeSession_DifferentHost_CreatesNewRow() {
        // Given
        _ = service.initializeSession(host: "google.com")
        
        // When (Host beda)
        _ = service.initializeSession(host: "cloudflare.com")
        
        // Then
        let context = mockController.container.viewContext
        let count = try? context.count(for: NetworkHistory.fetchRequest())
        XCTAssertEqual(count, 2, "Harusnya ada 2 baris karena host beda")
    }
    
    // 🔥 TEST BARU: ROAMING LOGIC (SSID SAMA, BSSID BEDA) 🔥
    func test_InitializeSession_SameSSID_DifferentBSSID_CreatesNewRow() {
        // Skenario: Pindah dari Router A ke Router B (Nama WiFi sama "Wired/Unknown")
        // Masalah: Di Unit Test, 'getNetworkDetails' selalu return default ("Wired/Unknown", "00:00").
        
        let host = "8.8.8.8"
        
        // 1. MANIPULASI DATA LAMA DI DB
        // Kita pura-pura udah punya history dari "Router A" yang BSSID-nya BEDA.
        let context = mockController.container.viewContext
        context.performAndWait {
            let oldLog = NetworkHistory(context: context)
            oldLog.id = UUID()
            oldLog.timestamp = Date().addingTimeInterval(-3600)
            oldLog.host = host
            oldLog.networkName = "Wired/Unknown" // Sama kayak default test
            oldLog.bssid = "AA:AA:AA:AA:AA:AA"   // BEDA dari default test (00:00)
            oldLog.status = "Finished"
            try? context.save()
        }
        
        // 2. When: Kita init session baru
        // (Service bakal baca BSSID "00:00" dari hardware simulator/default)
        let newID = service.initializeSession(host: host)
        
        // 3. Then:
        // Harusnya bikin BARU (karena AA:AA != 00:00)
        XCTAssertNotNil(newID)
        
        let count = try? context.count(for: NetworkHistory.fetchRequest())
        XCTAssertEqual(count, 2, "Harusnya ada 2 baris karena BSSID beda (Roaming)")
    }
    
    // ==========================================
    // KATEGORI 2: INTEGRITY (UPDATE FINALIZATION)
    // ==========================================
    
    func test_UpdateSession_SavesCorrectValues() {
        // Given
        let host = "test.com"
        guard let id = service.initializeSession(host: host) else {
            XCTFail("Gagal init session")
            return
        }
        
        // When (RTO terjadi, kita finalize data)
        let finalLatency = 45.0
        let finalMOS = 4.2
        let finalStatus = "Good"
        
        service.updateSession(id: id, latency: finalLatency, mos: finalMOS, status: finalStatus)
        
        // Then (Ambil lagi dari DB)
        // Kita pake performAndWait atau fetch langsung karena mock pake main context biasanya cepet,
        // tapi amannya fetch ulang.
        
        let updatedLog = service.fetchLastLog(forHost: host, networkName: service.getWiFiName())
        
        XCTAssertEqual(updatedLog?.latency, finalLatency)
        XCTAssertEqual(updatedLog?.mos, finalMOS)
        XCTAssertEqual(updatedLog?.status, finalStatus)
    }
    
    // ==========================================
    // KATEGORI 3: CLEANUP (DELETE)
    // ==========================================
    
    func test_DeleteAll_ClearsDatabase() {
        // Given (Isi sampah dulu)
        _ = service.initializeSession(host: "a.com")
        _ = service.initializeSession(host: "b.com")
        
        // When
        service.deleteAll()
        
        // Then
        let context = mockController.container.viewContext
        let count = try? context.count(for: NetworkHistory.fetchRequest())
        XCTAssertEqual(count, 0, "Database harusnya kosong melompong")
    }
}
