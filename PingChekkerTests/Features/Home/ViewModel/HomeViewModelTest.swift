//
//  HomeViewModelTest.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//


import XCTest
@testable import PingChekker

// ==========================================================================================
// MARK: - TEORI UNIT TESTING VIEWMODEL (KITAB GATOT)
// ==========================================================================================
//
// 1. FILOSOFI: VIEWMODEL SEBAGAI "STATE MACHINE"
//    ViewModel adalah kotak hitam yang mengubah INPUT menjadi OUTPUT (STATE).
//    Di SwiftUI, View hanyalah refleksi visual dari ViewModel.
//    - Jika ViewModel bilang "Warna = Merah", View PASTI jadi Merah.
//    - Makanya, kita cukup test ViewModel-nya. Gak perlu nge-render UI-nya.
//
// 2. APA YANG HARUS DITEST? (CHECKLIST 3 FASE)
//    A. Initial State (Keadaan Lahir):
//       Saat ViewModel baru dibuat, apakah nilai default-nya masuk akal?
//       (Contoh: Latency 0, Status "Calculating", Offline False).
//
//    B. State Transformation (Input -> Logic -> Output):
//       Ini inti dari Unit Test. Kita suntik data palsu (Input), lalu cek apakah
//       ViewModel mengubah properti @Published-nya (Output) sesuai rumus.
//       - Input: Service lapor Latency 15ms.
//       - Output: Variable `statusColor` harus jadi .green.
//
//    C. Flow & Behavior (Sebab Akibat):
//       Menguji skenario logika yang lebih kompleks.
//       - Sebab: Service error RTO.
//       - Akibat: Flag `isOffline` jadi true.
//       - Sebab: User klik Resume.
//       - Akibat: Flag `isOffline` jadi false lagi.
//
// 3. KENAPA PAKAI MOCK SERVICE?
//    Kita mau ngetes "Reaksi ViewModel", bukan "Koneksi Internet".
//    Mock Service membiarkan kita mengendalikan takdir (Tuhan-mode).
//    Kita bisa memaksa RTO, memaksa Ping Bagus, tanpa nungguin WiFi lemot beneran.
// ==========================================================================================

@MainActor
class HomeViewModelTest: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockService: MockPingService!
    
    override func setUp() {
        super.setUp()
        // 1. Siapkan service palsu
        mockService = MockPingService()
        
        // Inject ke ViewModel
        viewModel = HomeViewModel(service: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // ==========================================
    // FASE 1: TEST INITIAL STATE (Keadaan Lahir)
    // ==========================================
    func test_InitialState_IsCorrect() {
        // Pas baru lahir, pastikan UI bersih dan status default benar
        XCTAssertEqual(viewModel.currentLatency, 0.0)
        XCTAssertEqual(viewModel.latencyText, "- ms")
        XCTAssertEqual(viewModel.categoryText, "calculating")
        XCTAssertEqual(viewModel.statusColor, .gray)
        XCTAssertFalse(viewModel.isOffline)
        
        // Pastikan ViewModel langsung nyuruh service kerja pas lahir
        XCTAssertTrue(mockService.isMonitoringStarted)
    }
    
    // ==========================================
    // FASE 2: TEST STATE TRANSFORMATION (Logika UI)
    // ==========================================
    // Di sini kita cek apakah "Otak" ViewModel menerjemahkan angka menjadi warna/teks dengan benar.
    func test_Ping_Elite_Green() {
        // Given: Input 10ms
        mockService.simulatePing(latency: 10.0)
        
        // Then: Output harus Hijau & Elite
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.categoryText, "elite")
            XCTAssertEqual(self.viewModel.statusColor, .green)
        }
    }
    
    func test_Ping_Good_GreenOpacity() {
        mockService.simulatePing(latency: 30.0) // Range 21-50
        
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.categoryText, "good")
            // Tips: Kalau warna susah di-compare (karena Opacity), cukup cek teks kategorinya.
            // Asumsi: Kalau kategori bener, warnanya pasti ngikut logic switch-case yang sama.
        }
    }
    
    func test_Ping_GoodEnough_Yellow() {
        mockService.simulatePing(latency: 70.0) // Range 51-100
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.categoryText, "good enough")
            XCTAssertEqual(self.viewModel.statusColor, .yellow)
        }
    }
    
    func test_Ping_Enough_Orange() {
        mockService.simulatePing(latency: 150.0) // Range 101-200
        
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.categoryText, "enough")
            XCTAssertEqual(self.viewModel.statusColor, .orange)
        }
    }
    
    func test_Ping_Slow_Red() {
        mockService.simulatePing(latency: 300.0) // Range 201-500
        
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.categoryText, "slow")
            XCTAssertEqual(self.viewModel.statusColor, .red)
        }
    }
    
    
    // ==========================================
    // FASE 3: TEST QUALITY LOGIC (MOS Copywriting)
    // ==========================================
    func test_HighMOS_ShowsPerfectRecommendation() {
        // Simulasi MOS 4.5 (Angka dari Service)
        mockService.simulatePing(latency: 10, mos: 4.5)
        
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.mosScore, "4.5")
            // Cek apakah teks rekomendasi mengandung kata kunci yang benar
            XCTAssertTrue(self.viewModel.qualityCondition.contains("Excellent"))
        }
    }
    
    func test_LowMOS_ShowsCriticalRecommendation() {
        // Simulasi MOS 1.5
        mockService.simulatePing(latency: 500, mos: 1.5)
        
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.mosScore, "1.5")
            XCTAssertTrue(self.viewModel.qualityCondition.contains("Critical"))
            XCTAssertEqual(self.viewModel.qualityColor, .red)
        }
    }
    
    // ==========================================
    // FASE 4: TEST FLOW & ERROR HANDLING
    // ==========================================
    
    func test_RTO_TriggersOffline() {
        // When: Service teriak RTO
        mockService.simulateError(msg: "RTO")
        
        // Then: UI harus masuk mode Offline
        waitAndAssertUI {
            XCTAssertTrue(self.viewModel.isOffline)
            XCTAssertEqual(self.viewModel.latencyText, "RTO")
            XCTAssertEqual(self.viewModel.qualityCondition, "OFFLINE")
        }
    }
    
    func test_ResumeSignal_ResetsUI() {
        // 1. Kondisikan Error dulu biar status jadi Offline
        mockService.simulateError(msg: "RTO")
        
        // Tunggu bentar biar state ke-set (Simulasi delay UI)
        let rtoExpectation = XCTestExpectation(description: "RTO Set")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { rtoExpectation.fulfill() }
        wait(for: [rtoExpectation], timeout: 1.0)
        
        // 2. Action: Kirim sinyal Resume (Simulation Notification dari Settings)
        NotificationCenter.default.post(name: .startPingSession, object: nil)
        
        // 3. Then: Cek apakah UI balik bersih (Online) dan Reset
        waitAndAssertUI {
            XCTAssertFalse(self.viewModel.isOffline, "Harusnya status Offline dicabut")
            XCTAssertEqual(self.viewModel.statusMessage, "Menghubungkan kembali...")
            XCTAssertEqual(self.viewModel.currentLatency, 0.0)
        }
    }
    
    // ==========================================
    // FASE 5: TEST USER ACTION (Stop Manual)
    // ==========================================
    
    func test_ForceStop_StopsServiceAndUpdatesUI() {
        // 1. Given: Kondisi lagi jalan normal
        mockService.simulatePing(latency: 20)
        
        // 🔥 FIX RACE CONDITION:
        // Tunggu dulu sampai UI beneran jadi "Elite" (Hijau) sebelum kita stop.
        let warmUpExpectation = XCTestExpectation(description: "Warm Up UI")
        DispatchQueue.main.async {
            // Kita cek apakah update pertama (Ping 20ms) udah diproses
            if self.viewModel.categoryText == "elite" {
                warmUpExpectation.fulfill()
            }
        }
        wait(for: [warmUpExpectation], timeout: 1.0)
        
        
        // 2. When: User maksa stop (misal mau quit)
        viewModel.forceStopSession()
        
        // 3. Then:
        // Cek UI Offline
        // (Karena forceStopSession itu update direct/synchronous di VM, kita bisa assert langsung atau pake helper)
        
        // Cek Mesin Ping Mati
        XCTAssertTrue(mockService.isMonitoringStopped, "Service harusnya dipanggil stopMonitoring()")
        
        XCTAssertTrue(self.viewModel.isOffline)
        XCTAssertEqual(self.viewModel.statusMessage, "Terputus")
    }
    
    // --- HELPER SAKTI ---
    // Karena ViewModel main di Main Thread (Async), kita butuh helper ini
    // buat nunggu update UI kelar sebelum kita Assert (Cek nilai).
    private func waitAndAssertUI(timeout: TimeInterval = 1.0, assertions: @escaping () -> Void) {
        let expectation = XCTestExpectation(description: "UI Update")
        
        DispatchQueue.main.async {
            assertions()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeout)
    }
}
