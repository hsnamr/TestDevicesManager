//
//  TDMTests.swift
//  TDMTests
//
//  Created by Hussian Ali Al-Amri on 11/9/16.
//  Copyright © 2016 IM. All rights reserved.
//

import XCTest

final class TDMTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        // Example functional test case.
    }

    func testPerformanceExample() {
        measure {
            // Performance test.
        }
    }

    func testAdd() {
        let expectation = expectation(description: "Add")
        WebService.shared.addDevice(name: "iPhone 3G", os: "iOS 2", manufacturer: "Apple") { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testDelete() {
        let expectation = expectation(description: "Delete")
        WebService.shared.deleteDevice(id: 1) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testUnsyncedDeletes() {
        MainController.shared.writeUnsyncedDeletes(id: 2)
        MainController.shared.writeUnsyncedDeletes(id: 3)
        XCTAssertNotNil(PersistenceService.shared.read(name: "UnsyncedDeletes"))

        var unsyncedCount = PersistenceService.shared.read(name: "UnsyncedDeletes")?.count
        XCTAssertEqual(unsyncedCount, 2)

        let syncedDeletes = MainController.shared.syncOfflineDeletes()
        unsyncedCount = PersistenceService.shared.read(name: "UnsyncedDeletes")?.count ?? 0
        XCTAssertEqual(syncedDeletes, 2 - unsyncedCount)
    }

    func testUnsyncedUpdatesAndDeletes() {
        MainController.shared.writeUnsyncedUpdates(id: 2)
        MainController.shared.writeUnsyncedUpdates(id: 3)
        MainController.shared.writeUnsyncedUpdates(id: 0)
        MainController.shared.writeUnsyncedUpdates(id: 1)
        MainController.shared.writeUnsyncedUpdates(id: 4)
        XCTAssertNotNil(PersistenceService.shared.read(name: "UnsyncedUpdates"))

        var unsyncedUpdatesCount = PersistenceService.shared.read(name: "UnsyncedUpdates")?.count
        XCTAssertEqual(unsyncedUpdatesCount, 5)

        MainController.shared.writeUnsyncedDeletes(id: 2)
        MainController.shared.writeUnsyncedDeletes(id: 3)
        XCTAssertNotNil(PersistenceService.shared.read(name: "UnsyncedDeletes"))

        let unsyncedDeletesCount = PersistenceService.shared.read(name: "UnsyncedDeletes")?.count
        XCTAssertEqual(unsyncedDeletesCount, 2)

        unsyncedUpdatesCount = PersistenceService.shared.read(name: "UnsyncedUpdates")?.count
        XCTAssertEqual(unsyncedUpdatesCount, 3)

        let syncedUpdates = MainController.shared.syncOfflineUpdates()
        unsyncedUpdatesCount = PersistenceService.shared.read(name: "UnsyncedUpdates")?.count ?? 0
        XCTAssertEqual(syncedUpdates, 3 - unsyncedUpdatesCount)
    }
}
