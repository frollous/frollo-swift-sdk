//
//  MessageTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class MessageTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingMessage() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        let messageResponse = APIMessageResponse.testCompleteData()
        
        let message: Message
        switch messageResponse.contentType {
            case .html5:
                message = MessageHTML(context: managedObjectContext)
            case .textAndImage:
                message = MessageImage(context: managedObjectContext)
            case .text:
                message = MessageText(context: managedObjectContext)
            case .video:
                message = MessageVideo(context: managedObjectContext)
        }
        
        message.update(response: messageResponse, context: managedObjectContext)
        
        XCTAssertEqual(messageResponse.id, message.messageID)
        XCTAssertEqual(messageResponse.event, message.event)
        XCTAssertEqual(messageResponse.userEventID, message.userEventID)
        XCTAssertEqual(messageResponse.placement, message.placement)
        XCTAssertEqual(messageResponse.persists, message.persists)
        XCTAssertEqual(messageResponse.read, message.read)
        XCTAssertEqual(messageResponse.clicked, message.clicked)
        XCTAssertEqual(messageResponse.designType, message.designType)
        XCTAssertEqual(messageResponse.contentType, message.contentType)
        XCTAssertEqual(messageResponse.action?.title, message.actionTitle)
        XCTAssertEqual(messageResponse.action?.link, message.actionURLString)
        XCTAssertEqual(messageResponse.action?.openExternal, message.actionOpenExternal)
        XCTAssertEqual(messageResponse.button?.title, message.buttonTitle)
        XCTAssertEqual(messageResponse.button?.link, message.buttonURLString)
        XCTAssertEqual(messageResponse.button?.openExternal, message.buttonOpenExternal)
        
        for messageType in messageResponse.messageTypes {
            switch messageType {
                case .creditScore:
                    XCTAssertTrue(message.typeCreditScore)
                case .feed:
                    XCTAssertTrue(message.typeFeed)
                case .goalNudge:
                    XCTAssertTrue(message.typeGoal)
                case .homeNudge:
                    XCTAssertTrue(message.typeHome)
                case .popup:
                    XCTAssertTrue(message.typePopup)
                case .setupNudge:
                    XCTAssertTrue(message.typeSetup)
                case .welcomeNudge:
                    XCTAssertTrue(message.typeWelcome)
            }
        }
        
        if let contents = messageResponse.content {
            switch contents {
                case .html(let htmlContent):
                    if let htmlMessage = message as? MessageHTML {
                        XCTAssertEqual(htmlMessage.body, htmlContent.body)
                    } else {
                        XCTFail("Wrong message type")
                    }
                case .image(let imageContent):
                    if let imageMessage = message as? MessageImage {
                        XCTAssertEqual(imageMessage.height, imageContent.height)
                        XCTAssertEqual(imageMessage.width, imageContent.width)
                        XCTAssertEqual(imageMessage.urlString, imageContent.url)
                    } else {
                        XCTFail("Wrong message type")
                    }
                case .text(let textContent):
                    if let textMessage = message as? MessageText {
                        XCTAssertEqual(textMessage.body, textContent.body)
                        // TODO: More checks
                    } else {
                        XCTFail("Wrong message type")
                    }
                case .video(let videoContent):
                    if let videoMessage = message as? MessageVideo {
                        XCTAssertEqual(videoMessage.autoplay, videoContent.autoplay)
                        XCTAssertEqual(videoMessage.autoplayCellular, videoContent.autoplayCellular)
                        XCTAssertEqual(videoMessage.muted, videoContent.muted)
                        XCTAssertEqual(videoMessage.urlString, videoContent.url)
                        XCTAssertEqual(videoMessage.height, videoContent.height)
                        XCTAssertEqual(videoMessage.width, videoContent.width)
                    } else {
                        XCTFail("Wrong message type")
                    }
            }
        } else {
            XCTFail("No content parsed")
        }
    }

}
