//
//  SettingViewModelTest.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//

import XCTest
import Combine
@testable import PingChekker

@MainActor
class SettingsViewModelTests: XCTestCase {
    
    var viewModel: SettingsViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        
        // 1. Reset Global State sebelum test dimulai
        // Karena SettingsViewModel nempel langsung ke Singleton (HistoryService.shared),
        // kita harus pastiin kondisinya bersih/default (False).
        HistoryService.shared.isMonitoring = false
        
        // 2. Init ViewModel
        viewModel = SettingsViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        
        // Bersihkan jejak
        HistoryService.shared.isMonitoring = false
        super.tearDown()
    }
    
    // ==========================================
    // 1. TEST INITIAL STATE (Keadaan Lahir)
    // ==========================================
    
    func test_Init_ReflectsServiceState_False() {
        // Given: Service mati
        HistoryService.shared.isMonitoring = false
        
        // When: ViewModel lahir
        let vm = SettingsViewModel()
        
        // Then: UI harus mati (tombol ijo)
        XCTAssertFalse(vm.isMonitoring)
    }
    
    func test_Init_ReflectsServiceState_True() {
        // Given: Service lagi jalan
        HistoryService.shared.isMonitoring = true
        
        // When: ViewModel lahir (misal user baru buka window settings)
        let vm = SettingsViewModel()
        
        // Then: UI harus idup (tombol abu/disabled)
        XCTAssertTrue(vm.isMonitoring)
    }
    
    // ==========================================
    // 2. TEST REACTIVE STATE (Sinkronisasi)
    // ==========================================
    
    func test_ServiceUpdate_UpdatesViewModel_Automatically() {
        // Skenario: User klik Stop di Dashboard -> Service berubah -> Settings harus ikut berubah
        
        // Given: Awal mati
        XCTAssertFalse(viewModel.isMonitoring)
        
        let expectation = XCTestExpectation(description: "ViewModel denger perubahan")
        
        // Kita "mata-matai" properti viewModel.isMonitoring
        viewModel.$isMonitoring
            .dropFirst() // Abaikan nilai awal
            .sink { isMonitoring in
                if isMonitoring == true {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When: Service berubah jadi TRUE (Simulasi Start)
        // Ini akan memicu NotificationCenter internal di dalam Service
        HistoryService.shared.isMonitoring = true
        
        // Then: ViewModel harus update otomatis dalam < 1 detik
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isMonitoring)
    }
    
    // ==========================================
    // 3. TEST ACTION (Tombol Resume)
    // ==========================================
    
    func test_ResumeMonitoring_PostsStartSignal() {
        // Skenario: User klik tombol "Resume Monitoring"
        
        // Given: Kita pasang alat sadap di NotificationCenter
        let expectation = XCTNSNotificationExpectation(name: .startPingSession)
        
        // When: Tombol diklik
        viewModel.resumeMonitoring()
        
        // Then: Sinyal harus terkirim (biar HomeViewModel nangkep)
        wait(for: [expectation], timeout: 1.0)
        
        // Catatan: Kita gak bisa ngetes `NSApp.activate` di Unit Test karena itu UI behavior,
        // tapi kita bisa pastiin logic pengiriman sinyalnya bener.
    }
}
