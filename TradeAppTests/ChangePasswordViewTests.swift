//
//  ChangePasswordViewTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 01/01/2024.
//

import XCTest
@testable import TradeApp

final class ChangePasswordViewTests: XCTestCase {

    // check password format
    func testSuccessIsPasswordValid() {
        // Given (Arrange)
        let password = "passWord123"
        let vc = ChangePasswordView()
        // When (Act)
        let result = vc.isPasswordValid(password)
        // Then (Arrange)
        XCTAssertTrue(result)
    }
    
    // check password format
    func testFailureIsPasswordValid() {
        // Given (Arrange)
        let password = "verylongpassWord"
        let vc = ChangePasswordView()
        // When (Act)
        let result = vc.isPasswordValid(password)
        // Then (Arrange)
        XCTAssertFalse(result)
    }

}
