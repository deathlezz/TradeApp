//
//  ChangeEmailViewTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 01/01/2024.
//

import XCTest
@testable import TradeApp

final class ChangeEmailViewTests: XCTestCase {

    // check email address format
    func testSuccessIsEmailValid() {
        // Given (Arrange)
        let email = "mail@icloud.com"
        let vc = ChangeEmailView()
        // When (Act)
        let result = vc.isEmailValid(email)
        // Then (Assert)
        XCTAssertTrue(result)
    }
    
    // check email address format
    func testFailureIsEmailValid() {
        // Given (Arrange)
        let email = "mail@icloud,com"
        let vc = ChangeEmailView()
        // When (Act)
        let result = vc.isEmailValid(email)
        // Then (Assert)
        XCTAssertFalse(result)
    }

}
