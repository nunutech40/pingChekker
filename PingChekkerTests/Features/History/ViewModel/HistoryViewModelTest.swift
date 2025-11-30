//
//  HistoryViewModelTest.swift
//  PingChekker
//
//  Created by Nunu Nugraha on 30/11/25.
//


import XCTest
import CoreData
@testable import PingChekker

// ==========================================================================================
// MARK: - KITAB UNIT TEST VIEWMODEL (TEORI GATOT)
// ==========================================================================================
//
// 1. FILOSOFI: APA YANG PERLU DITEST DI VIEWMODEL?
//    ViewModel adalah "Otak" yang mengubah Data/Input menjadi State UI.
//    Kita TIDAK ngetes UI (apakah tombol muncul?), tapi ngetes STATE (apakah variable showAlert jadi true?).
//
// 2. CHECKLIST PENGUJIAN (HISTORY VIEWMODEL):
//    A. LOGIC MURNI (FORMAT DATA):
//       - Apakah tanggal diformat sesuai request "dd-MM-yyyy:HH.mm"?
//       - Apakah angka MOS diterjemahkan jadi Warna/Teks yang bener?
//
//    B. SAFETY GUARDS (SATPAM):
//       - Mencegah user menghapus data saat monitoring sedang jalan.
//       - HARAPAN: Muncul Alert Error, bukan Alert Konfirmasi.
//
//    C. FLOW LOGIC (ALUR):
//       - Saat kondisi aman (Idle), apakah request delete memunculkan konfirmasi?
//       - Setelah konfirmasi, apakah state sementara (itemToDelete) dibersihkan?
//
//    D. SIDE EFFECTS (EFEK SAMPING):
//       - ViewModel berjanji akan ngirim sinyal `.resetPingSession` kalau user klik "Clear All".
//       - Kita wajib tes apakah janji itu ditepati (Sinyal terkirim).
//
// 3. KENAPA GAK ADA TEST ERROR DATABASE?
//    - "Error Apa Dulu?"
//    - Kodingan HistoryViewModel saat ini TIDAK PUNYA mekanisme error handling untuk kegagalan DB
//      (seperti Disk Full/Corrupt). UI-nya "bisu" soal itu, jadi gak ada variable error yang bisa dites.
//    - TAPI, kita sudah ngetes "User Error" (Hapus pas lagi jalan) di poin B. Itu Error Handling UI.
//
// ==========================================================================================

@MainActor
class HistoryViewModelTests: XCTestCase {
    
    var viewModel: HistoryViewModel!
    var mockContext: NSManagedObjectContext!
    // Kita simpan controller-nya biar service & context sinkron
    var mockController: PresistanceController!
    var mockService: HistoryService!
    
    override func setUp() {
        super.setUp()
        
        // 1. Setup Database RAM (Satu Sumber Kebenaran)
        mockController = PresistanceController(inMemory: true)
        mockContext = mockController.container.viewContext
        
        // 2. Setup Service Palsu (Pake DB RAM tadi)
        mockService = HistoryService(controller: mockController)
        mockService.isMonitoring = false // Reset state
        
        // 3. Setup ViewModel dengan Injection
        // Pastikan lu udah update HistoryViewModel biar punya init(service:)
        viewModel = HistoryViewModel(service: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockContext = nil
        mockController = nil
        mockService = nil
        super.tearDown()
    }
    
    // ==========================================
    // 1. TEST LOGIC FORMATTER (MURNI)
    // ==========================================
    
    func test_DateFormatter_ReturnsCorrectString() {
        var components = DateComponents()
        components.year = 1990; components.month = 8; components.day = 17
        components.hour = 12; components.minute = 30
        let date = Calendar.current.date(from: components)
        
        let result = viewModel.getFormattedDate(date)
        XCTAssertEqual(result, "17-08-1990:12.30")
    }
    
    func test_DateFormatter_WithNil_ReturnsDash() {
        XCTAssertEqual(viewModel.getFormattedDate(nil), "-")
    }
    
    // ==========================================
    // 2. TEST LOGIC MOS UI (WARNA & TEKS)
    // ==========================================
    
    func test_MOS_Zero_ReturnsMonitoringState() {
        let result = viewModel.evaluateQuality(mos: 0.0)
        XCTAssertEqual(result.status, "Monitoring...")
        XCTAssertEqual(result.color, .blue)
    }
    
    func test_MOS_High_ReturnsExcellent() {
        let result = viewModel.evaluateQuality(mos: 4.5)
        XCTAssertEqual(result.status, "Excellent", "Harusnya Excellent")
        XCTAssertEqual(result.color, .green)
    }
    
    func test_MOS_Low_ReturnsCritical() {
        let result = viewModel.evaluateQuality(mos: 1.5)
        XCTAssertTrue(result.status.contains("Critical"))
        XCTAssertEqual(result.color, .red)
    }
    
    // ==========================================
    // 3. TEST LOGIC ALERT (REQUEST DELETE)
    // ==========================================
    
    func test_RequestDelete_WhileMonitoring_ShowsRunningAlert() {
        // Given: Lagi sibuk nge-ping
        mockService.isMonitoring = true // Update di service instance kita
        
        let item = NetworkHistory(context: mockContext)
        
        // When
        viewModel.requestDelete(item: item)
        
        // Then
        XCTAssertTrue(viewModel.showRunningAlert)
        XCTAssertFalse(viewModel.showDeleteConfirmation)
        XCTAssertNil(viewModel.itemToDelete)
    }
    
    func test_RequestDelete_WhileIdle_ShowsConfirmation() {
        // Given: Lagi santai
        mockService.isMonitoring = false
        
        let item = NetworkHistory(context: mockContext)
        
        // When
        viewModel.requestDelete(item: item)
        
        // Then
        XCTAssertFalse(viewModel.showRunningAlert)
        XCTAssertTrue(viewModel.showDeleteConfirmation)
        XCTAssertNotNil(viewModel.itemToDelete)
        XCTAssertEqual(viewModel.itemToDelete, item)
    }
    
    // ==========================================
    // 4. TEST STATE RESET (CONFIRMATION)
    // ==========================================
    
    func test_ConfirmDelete_ResetsItemToDelete() {
        // Given: Objek dibuat di Context yang SAMA dengan Service
        let item = NetworkHistory(context: mockContext)
        // Kita perlu save dulu biar dia punya ID permanen (opsional tapi good practice)
        try? mockContext.save()
        
        viewModel.itemToDelete = item
        
        // When: User klik "Yes Hapus" di alert
        // Ini bakal manggil mockService.deleteItem(item)
        // Karena item dan service pake context yang sama, GAK BAKAL CRASH.
        viewModel.confirmDelete()
        
        // Then
        XCTAssertNil(viewModel.itemToDelete, "Item to delete harus di-reset jadi nil setelah dihapus")
    }
    
    // ==========================================
    // 5. TEST CLEAR ALL REQUEST (LOGIC BUTTON)
    // ==========================================
    
    func test_RequestClearAll_Monitoring_ShowsAlert() {
        mockService.isMonitoring = true
        viewModel.requestClearAll()
        XCTAssertTrue(viewModel.showRunningAlert)
        XCTAssertFalse(viewModel.showClearAllConfirmation)
    }
    
    func test_RequestClearAll_Idle_ShowsConfirmation() {
        mockService.isMonitoring = false
        viewModel.requestClearAll()
        XCTAssertFalse(viewModel.showRunningAlert)
        XCTAssertTrue(viewModel.showClearAllConfirmation)
    }
    
    // ==========================================
    // 6. TEST SIDE EFFECT (SIGNAL BROADCAST)
    // ==========================================
    
    func test_ConfirmClearAll_PostsResetSignal() {
        // Given
        let expectation = XCTNSNotificationExpectation(name: .resetPingSession)
        
        // When
        viewModel.confirmClearAll()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
