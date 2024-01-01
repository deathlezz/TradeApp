//
//  ChangeNumberViewTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 01/01/2024.
//

import XCTest
@testable import TradeApp

final class ChangeNumberViewTests: XCTestCase {

    // check phone number format
    func testSuccessIsPhoneNumberValid() {
        // Given (Arrange)
        let number = "+441234567890"
        let vc = ChangeNumberView()
        // When (Act)
        let result = vc.isNumberValid(number)
        // Then (Arrange)
        XCTAssertTrue(result)
    }
    
    // check phone number format
    func testFailureIsPhoneNumberValid() {
        // Given (Arrange)
        let number = "01234567890"
        let vc = ChangeNumberView()
        // When (Act)
        let result = vc.isNumberValid(number)
        // Then (Arrange)
        XCTAssertFalse(result)
    }
    

}
