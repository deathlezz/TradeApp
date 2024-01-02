//
//  EndedAdsViewTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 02/01/2024.
//

import XCTest
@testable import TradeApp

final class EndedAdsViewTests: XCTestCase {

    // check if item expiry date is correct
    func testSuccessSetExpiryDate() {
        // Given (Arrange)
        let stringDate = "May 26"
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MMM d"
        let customDate = dateFormatter.date(from: stringDate)!
        let formattedExpiryDate = dateFormatter.string(from: customDate)
        let vc = EndedAdsView()
        // When (Act)
        let result = vc.setExpiryDate(customDate)
        // Then (Assert)
        XCTAssertEqual(result, "expired \(formattedExpiryDate)")
    }
}
