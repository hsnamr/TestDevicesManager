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
}
