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

import XCTest
@testable import PingChekker

@MainActor
class HomeViewModelTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockService: MockPingService!
    
    override func setUp() {
        super.setUp()
        mockService = MockPingService()
        viewModel = HomeViewModel(service: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // ==========================================
    // FASE 1: TEST INITIAL STATE
    // ==========================================
    func test_InitialState_IsCorrect() {
        // Update String Key: "CALCULATING" (bukan "calculating")
        XCTAssertEqual(viewModel.currentLatency, 0.0)
        XCTAssertEqual(viewModel.latencyText, "- ms")
        XCTAssertEqual(viewModel.categoryText, "CALCULATING")
        XCTAssertEqual(viewModel.statusColor, .gray)
        XCTAssertFalse(viewModel.isOffline)
        
        XCTAssertTrue(mockService.isMonitoringStarted)
    }
    
    // ==========================================
    // FASE 2: TEST STATE TRANSFORMATION
    // ==========================================
    
    func test_Ping_Elite_Green() {
        mockService.simulatePing(latency: 10.0)
        
        waitAndAssertUI {
            // Update String Key: "ELITE"
            XCTAssertEqual(self.viewModel.categoryText, "ELITE")
            XCTAssertEqual(self.viewModel.statusColor, .green)
        }
    }
    
    func test_Ping_Good_GreenOpacity() {
        mockService.simulatePing(latency: 30.0)
        
        waitAndAssertUI {
            // Update String Key: "GOOD"
            XCTAssertEqual(self.viewModel.categoryText, "GOOD")
        }
    }
    
    func test_Ping_GoodEnough_Yellow() {
        mockService.simulatePing(latency: 70.0)
        
        waitAndAssertUI {
            // Update String Key: "GOOD ENOUGH"
            XCTAssertEqual(self.viewModel.categoryText, "GOOD ENOUGH")
            XCTAssertEqual(self.viewModel.statusColor, .yellow)
        }
    }
    
    func test_Ping_Enough_Orange() {
        mockService.simulatePing(latency: 150.0)
        
        waitAndAssertUI {
            // Update String Key: "ENOUGH"
            XCTAssertEqual(self.viewModel.categoryText, "ENOUGH")
            XCTAssertEqual(self.viewModel.statusColor, .orange)
        }
    }
    
    func test_Ping_Slow_Red() {
        mockService.simulatePing(latency: 300.0)
        
        waitAndAssertUI {
            // Update String Key: "SLOW"
            XCTAssertEqual(self.viewModel.categoryText, "SLOW")
            XCTAssertEqual(self.viewModel.statusColor, .red)
        }
    }
    
    // ==========================================
    // FASE 3: TEST QUALITY LOGIC
    // ==========================================
    
    func test_HighMOS_ShowsPerfectRecommendation() {
        mockService.simulatePing(latency: 10, mos: 4.5)
        
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.mosScore, "4.5")
            // Update String Key: "EXCELLENT"
            XCTAssertTrue(self.viewModel.qualityCondition.contains("EXCELLENT"))
        }
    }
    
    func test_LowMOS_ShowsCriticalRecommendation() {
        mockService.simulatePing(latency: 500, mos: 1.5)
        
        waitAndAssertUI {
            XCTAssertEqual(self.viewModel.mosScore, "1.5")
            // Update String Key: "CRITICAL"
            XCTAssertTrue(self.viewModel.qualityCondition.contains("CRITICAL"))
            XCTAssertEqual(self.viewModel.qualityColor, .red)
        }
    }
    
    // ==========================================
    // FASE 4: TEST FLOW & ERROR HANDLING
    // ==========================================
    
    func test_RTO_TriggersOffline() {
        mockService.simulateError(msg: "RTO")
        
        waitAndAssertUI {
            XCTAssertTrue(self.viewModel.isOffline)
            XCTAssertEqual(self.viewModel.latencyText, "RTO")
            // Update String Key: "OFFLINE"
            XCTAssertEqual(self.viewModel.qualityCondition, "OFFLINE")
            // Tambahan Cek Category: "NO CONNECTION"
            XCTAssertEqual(self.viewModel.categoryText, "NO CONNECTION")
        }
    }
    
    func test_ResumeSignal_ResetsUI() {
        // 1. Bikin error dulu
        mockService.simulateError(msg: "RTO")
        
        let rtoExpectation = XCTestExpectation(description: "RTO Set")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { rtoExpectation.fulfill() }
        wait(for: [rtoExpectation], timeout: 1.0)
        
        // 2. Kirim sinyal Resume
        NotificationCenter.default.post(name: .startPingSession, object: nil)
        
        // 3. Cek Reset
        waitAndAssertUI {
            XCTAssertFalse(self.viewModel.isOffline)
            // Update String Key: "Reconnecting..." (bukan Menghubungkan kembali)
            XCTAssertEqual(self.viewModel.statusMessage, "Reconnecting...")
            XCTAssertEqual(self.viewModel.currentLatency, 0.0)
        }
    }
    
    // ==========================================
    // FASE 5: TEST USER ACTION (Stop Manual)
    // ==========================================
    
    func test_ForceStop_StopsServiceAndUpdatesUI() {
        // 1. Given: Kondisi jalan normal
        mockService.simulatePing(latency: 20)
        
        // Warm Up: Tunggu UI jadi ELITE
        let warmUpExpectation = XCTestExpectation(description: "Warm Up UI")
        DispatchQueue.main.async {
            // Update String Key: "ELITE"
            if self.viewModel.categoryText == "ELITE" {
                warmUpExpectation.fulfill()
            }
        }
        wait(for: [warmUpExpectation], timeout: 1.0)
        
        
        // 2. When: Force Stop
        viewModel.forceStopSession()
        
        // 3. Then:
        // Cek Service Mati
        XCTAssertTrue(mockService.isMonitoringStopped)
        
        // Cek UI Offline
        XCTAssertTrue(self.viewModel.isOffline)
        // Update String Key: "Disconnected" (bukan Terputus)
        XCTAssertEqual(self.viewModel.statusMessage, "Disconnected")
    }
    
    // --- HELPER ---
    private func waitAndAssertUI(timeout: TimeInterval = 1.0, assertions: @escaping () -> Void) {
        let expectation = XCTestExpectation(description: "UI Update")
        DispatchQueue.main.async {
            assertions()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }
}
