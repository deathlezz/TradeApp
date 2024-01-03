//
//  UtilitiesTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 03/01/2024.
//

import XCTest
import CoreLocation
@testable import TradeApp

final class UtilitiesTests: XCTestCase {

    // check if message kind is converted into string
    func testSuccessGetMessageText() {
        // Given (Arrange)
        let sender = Sender(senderId: "1234", displayName: "sender")
        let message = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .text("random text message"))
        // When (Act)
        let result = message.kind.getMessageText()
        // Then (Assert)
        XCTAssertEqual(result, "random text message")
    }
    
    // check if message kind is converted into string
    func testWrongInputGetMessageText() {
        // Given (Arrange)
        let sender = Sender(senderId: "1234", displayName: "sender")
        let message = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .emoji("emoji"))
        // When (Act)
        let result = message.kind.getMessageText()
        // Then (Assert)
        XCTAssertEqual(result, "")
    }
    
    // check if date is converted into string
    func testRegularDateToString() {
        // Given (Arrange)
        let dateString = "2024-01-02 13:11:22"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let customDate = formatter.date(from: dateString)
        // When (Act)
        let result = customDate?.toString(shortened: false)
        // Then (Arrange)
        XCTAssertEqual(result, "2 Jan 2024, 13:11")
    }
    
    // check if date is converted into string
    func testShortDateToString() {
        // Given (Arrange)
        let dateString = "2024-01-02 13:11:22"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let customDate = formatter.date(from: dateString)
        // When (Act)
        let result = customDate?.toString(shortened: true)
        // Then (Arrange)
        XCTAssertEqual(result, "2 Jan, 13:11")
    }
    
    // check if date is converted into string
    func testWrongInputToString() {
        // Given (Arrange)
        let dateString = "2024-01-32 13:11:22"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let customDate = formatter.date(from: dateString)
        // When (Act)
        let result = customDate?.toString(shortened: true)
        // Then (Arrange)
        XCTAssertNil(result)
    }
    
    // check if string is converted into date
    func testSuccessToDate() {
        // Given (Arrange)
        let stringDate = "2 Jan 2024, 13:11"
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        let customDate = formatter.date(from: stringDate)
        // When (Act)
        let result = stringDate.toDate()
        // Then (Assert)
        XCTAssertEqual(result, customDate)
    }
    
    // check if city exists
    func testSuccessIsCityValid() {
        // Given (Arrange)
        let city = "London"
        let expectation = self.expectation(description: "Valid City Expectation")
        // When (Act)
        Utilities.isCityValid(city) { valid in
            // Then (Assert)
            XCTAssertTrue(valid)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // check if city exists
    func testFailureIsCityValid() {
        // Given (Arrange)
        let city = "Londnn"
        let expectation = self.expectation(description: "Valid City Expectation")
        // When (Act)
        Utilities.isCityValid(city) { valid in
            // Then (Assert)
            XCTAssertFalse(valid)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    // check if city name is converted into coordinates
    func testSuccessForwardGeocoding() {
        // Given (Arrange)
        let city = "Edinburgh"
        let latitude = 55.949821
        let longitute = -3.1902952
        let expectation = self.expectation(description: "City Coordinates Expectation")
        // When (Act)
        Utilities.forwardGeocoding(address: city) { (lat, long) in
            // Then (Assert)
            XCTAssertEqual(lat, latitude)
            XCTAssertEqual(long, longitute)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
}
