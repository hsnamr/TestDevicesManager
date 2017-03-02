//
//  JnJCCATests.swift
//  JnJCCATests
//
//  Created by Hussian Ali Al-Amri on 11/9/16.
//  Copyright © 2016 IM. All rights reserved.
//

import XCTest

class JnJCCATests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAdd() {
        let addExpectation = expectation(description: "Add")
        WebService.shared.addDevice(name: "iPhone 3G", os: "iOS 2", manufacturer: "Apple", completion: { string in
            XCTAssertNotNil(string, "Success")
            addExpectation.fulfill()
        })
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testDelete() {
        let deleteExpectation = expectation(description: "Delete")
        WebService.shared.deleteDevice(id: Int16(1), completion: { string in
            XCTAssertNotNil(string, "Success")
            deleteExpectation.fulfill()
        })
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testUnsyncedDeletes() {
        // fake delete some devices
        MainController.shared.writeUnsyncedDeletes(id: 2)   // 1
        MainController.shared.writeUnsyncedDeletes(id: 3)   // 2
        // unsyncedDeletes cannot be nil
        XCTAssertNotNil(PersistenceService.shared.read(name: "UnsyncedDeletes"))
        
        // unsynced devices count should be two
        var unsyncedDeletes = PersistenceService.shared.read(name: "UnsyncedDeletes")?.count
        XCTAssertEqual(unsyncedDeletes, 2)
        
        // perform sync and check number of synced and unsynced (connection might have dropped during sync)
        let syncedDeletes = MainController.shared.syncOfflineDeletes()
        unsyncedDeletes = PersistenceService.shared.read(name: "UnsyncedDeletes")?.count ?? 0
        XCTAssertEqual(syncedDeletes, 2 - unsyncedDeletes!)
    }
    
    func testUnsyncedUpdatesAndDeletes() {
        // fake update some devices
        MainController.shared.writeUnsyncedUpdates(id: 2)   // 1
        MainController.shared.writeUnsyncedUpdates(id: 3)   // 2
        MainController.shared.writeUnsyncedUpdates(id: 0)   // 3
        MainController.shared.writeUnsyncedUpdates(id: 1)   // 4
        MainController.shared.writeUnsyncedUpdates(id: 4)   // 5
        // unsyncedDeletes cannot be nil
        XCTAssertNotNil(PersistenceService.shared.read(name: "UnsyncedUpdates"))
        
        // unsynced updates count should be five
        var unsyncedUpdates = PersistenceService.shared.read(name: "UnsyncedUpdates")?.count
        XCTAssertEqual(unsyncedUpdates, 5)
        
        // what if some were deleted?
        // fake delete some devices
        MainController.shared.writeUnsyncedDeletes(id: 2)   // 1
        MainController.shared.writeUnsyncedDeletes(id: 3)   // 2
        // unsyncedDeletes cannot be nil
        XCTAssertNotNil(PersistenceService.shared.read(name: "UnsyncedDeletes"))
        
        // unsynced deletes count should be two
        let unsyncedDeletes = PersistenceService.shared.read(name: "UnsyncedDeletes")?.count
        XCTAssertEqual(unsyncedDeletes, 2)
        
        // unsynced updates count should be three
        unsyncedUpdates = PersistenceService.shared.read(name: "UnsyncedUpdates")?.count
        XCTAssertEqual(unsyncedUpdates, 3)
        
        // perform sync and check number of synced and unsynced (connection might have dropped during sync)
        let syncedUpdates = MainController.shared.syncOfflineUpdates()
        unsyncedUpdates = PersistenceService.shared.read(name: "UnsyncedUpdates")?.count ?? 0
        XCTAssertEqual(syncedUpdates, 3 - unsyncedUpdates!)
    }
}
