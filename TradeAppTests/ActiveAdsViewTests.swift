//
//  ActiveAdsViewTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 02/01/2024.
//

import XCTest
@testable import TradeApp

final class ActiveAdsViewTests: XCTestCase {

    // check if item expiry date is correct
    func testSuccessSetExpiryDate() {
        // Given (Arrange)
        let userCalendar = Calendar.current
        let expiryDate = userCalendar.date(byAdding: .day, value: 30, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MMMM d"
        let formattedExpiryDate = dateFormatter.string(from: expiryDate)
        let vc = ActiveAdsView()
        // When (Act)
        let result = vc.setExpiryDate(Date())
        // Then (Assert)
        XCTAssertEqual(result, "expires \(formattedExpiryDate)")
    }
    
    

}
