//
//  MessagesViewTests.swift
//  TradeAppTests
//
//  Created by deathlezz on 01/01/2024.
//

import XCTest
@testable import TradeApp

final class MessagesViewTests: XCTestCase {

    // check if MessageKind is converted into String
    func testShortInputGetMessageText() {
        // Given (Arrange)
        let sender = Sender(senderId: "1234", displayName: "sender")
        let message = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .text("test message"))
        let vc = MessagesView()
        // When (Act)
        let result = vc.getMessageText(message.kind)
        // Then (Assert)
        XCTAssertEqual(result, "test message")
    }
    
    // check if MessageKind is converted into String and has the right number of letters
    func testLongInputGetMessageText() {
        // Given (Arrange)
        let sender = Sender(senderId: "1234", displayName: "sender")
        let message = Message(sender: sender, messageId: "0", sentDate: Date(), kind: .text("test message but longest as possible possible possible"))
        let width = UIScreen.main.bounds.width
        let maxLetters = Int(width / 17)
        let vc = MessagesView()
        // When (Act)
        let result = vc.getMessageText(message.kind)
        // Then (Assert)
        XCTAssertEqual(result.count, maxLetters + 3)
    }
    
    // check if today's date is showed as "10:00"
    func testTodayConvertDate() {
        // Given (Arrange)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTime = dateFormatter.string(from: Date())
        let vc = MessagesView()
        // When (Act)
        let result = vc.convertDate(Date())
        // Then (Assert)
        XCTAssertEqual(result, currentTime)
    }
    
    // check if yesterday's date is showed as "Yesterday"
    func testYesterdayConvertDate() {
        // Given (Arrange)
        let vc = MessagesView()
        // When (Act)
        let result = vc.convertDate(Date().addingTimeInterval(-86400))
        // Then (Assert)
        XCTAssertEqual(result, "Yesterday")
    }
    
    // check if any other day's date is showed as "May 26"
    func testAnyOtherDayConvertDate() {
        // Given (Arrange)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let date = dateFormatter.string(from: Date().addingTimeInterval(-172800))
        let vc = MessagesView()
        // When (Act)
        let result = vc.convertDate(Date().addingTimeInterval(-172800))
        // Then (Assert)
        XCTAssertEqual(result, date)
    }
}
