//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

    func updateMessageTest(type: Message.ContentType) {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let messageResponse = APIMessageResponse.testCompleteData(type: type)
            
            let message: Message
            switch type {
            case .html:
                message = MessageHTML(context: managedObjectContext)
            case .image:
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
            XCTAssertEqual(messageResponse.interacted, message.interacted)
            XCTAssertEqual(messageResponse.title, message.title)
            XCTAssertEqual(messageResponse.contentType, message.contentType)
            XCTAssertEqual(messageResponse.messageTypes, message.messageTypes)
            XCTAssertEqual(messageResponse.action?.title, message.actionTitle)
            XCTAssertEqual(messageResponse.action?.link, message.actionURLString)
            XCTAssertEqual(messageResponse.action?.openExternal, message.actionOpenExternal)
            XCTAssertEqual(messageResponse.autoDismiss, message.autoDismiss)
            
            if let contents = messageResponse.content {
                switch contents {
                case .html(let htmlContent):
                    if let htmlMessage = message as? MessageHTML {
                        XCTAssertEqual(htmlMessage.footer, htmlContent.footer)
                        XCTAssertEqual(htmlMessage.header, htmlContent.header)
                        XCTAssertEqual(htmlMessage.main, htmlContent.main)
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
                        XCTAssertEqual(textMessage.footer, textContent.footer)
                        XCTAssertEqual(textMessage.header, textContent.header)
                        XCTAssertEqual(textMessage.imageURLString, textContent.imageURL)
                        XCTAssertEqual(textMessage.text, textContent.text)
                        XCTAssertEqual(textMessage.designType, textContent.designType)
                    } else {
                        XCTFail("Wrong message type")
                    }
                case .video(let videoContent):
                    if let videoMessage = message as? MessageVideo {
                        XCTAssertEqual(videoMessage.autoplay, videoContent.autoplay)
                        XCTAssertEqual(videoMessage.autoplayCellular, videoContent.autoplayCellular)
                        XCTAssertEqual(videoMessage.muted, videoContent.muted)
                        XCTAssertEqual(videoMessage.iconURLString, videoContent.iconURL)
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
    
    func testUpdatingHTMLMessage() {
        updateMessageTest(type: .html)
    }
    
    func testUpdatingImageMessage() {
        updateMessageTest(type: .image)
    }
    
    func testUpdatingTextMessage() {
        updateMessageTest(type: .text)
    }
    
    func testUpdatingVideoMessage() {
        updateMessageTest(type: .video)
    }
    
    func testMessageUpdateRequest() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let message = Message(context: managedObjectContext)
            message.populateTestData()
            
            let updateRequest = message.updateRequest()
            
            XCTAssertEqual(message.interacted, updateRequest.interacted)
            XCTAssertEqual(message.read, updateRequest.read)
        }
    }

}
