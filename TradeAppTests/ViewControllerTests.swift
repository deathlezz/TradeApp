//
//  ViewControllerTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 29/12/2023.
//

import XCTest
@testable import TradeApp

final class ViewControllerTests: XCTestCase {
    
    // check if item was added in the last 24h
    func testSuccessIsItemRecent() {
        // Given (Arrange)
        let date = Date.now.addingTimeInterval(-86399)
        let vc = ViewController()
        // When (Act)
        let recent = vc.isItemRecent(date)
        // Then (Assert)
        XCTAssertTrue(recent)
    }
    
    // check if item was not added in the last 24h
    func testFailureIsItemRecent() {
        // Given (Arrange)
        let date = Date.now.addingTimeInterval(-86401)
        let vc = ViewController()
        // When (Act)
        let recent = vc.isItemRecent(date)
        // Then (Assert)
        XCTAssertFalse(recent)
    }

}
