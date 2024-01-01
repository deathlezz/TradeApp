//
//  LoginViewTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 01/01/2024.
//

import XCTest
@testable import TradeApp

final class LoginViewTests: XCTestCase {

    // check email address format
    func testSuccessIsEmailValid() {
        // Given (Arrange)
        let email = "mail@icloud.com"
        let vc = LoginView()
        // When (Act)
        let result = vc.isEmailValid(email)
        // Then (Assert)
        XCTAssertTrue(result)
    }
    
    // check email address format
    func testFailureIsEmailValid() {
        // Given (Arrange)
        let email = "mail@icloud@com"
        let vc = LoginView()
        // When (Act)
        let result = vc.isEmailValid(email)
        // Then (Assert)
        XCTAssertFalse(result)
    }
    
    // check password format
    func testSuccessIsPasswordValid() {
        // Given (Arrange)
        let password = "passWord123"
        let vc = LoginView()
        // When (Act)
        let result = vc.isPasswordValid(password)
        // Then (Arrange)
        XCTAssertTrue(result)
    }
    
    // check password format
    func testFailureIsPasswordValid() {
        // Given (Arrange)
        let password = "password123"
        let vc = LoginView()
        // When (Act)
        let result = vc.isPasswordValid(password)
        // Then (Arrange)
        XCTAssertFalse(result)
    }

}
