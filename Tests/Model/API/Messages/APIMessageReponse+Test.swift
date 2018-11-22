//
//  APIMessageReponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIMessageResponse {
    
    static func testCompleteData(type: Message.ContentType? = nil) -> APIMessageResponse {
        let actionLink = APIMessageResponse.Link(link: "frollo://dashboard", openExternal: Bool.random(), title: String.randomString(range: 1...30))
        
        let htmlContent = APIMessageResponse.Content.HTML(footer: String.randomString(range: 1...10), header: String.randomString(range: 1...20), main: "<html></html>")
        let imageContent = APIMessageResponse.Content.Image(height: Double.random(in: 1...1000), url: "https://example.com/image.png", width: Double.random(in: 1...1000))
        let textContent = APIMessageResponse.Content.Text(designType: Message.Design.allCases.randomElement()!, footer: String.randomString(range: 1...20), header: String.randomString(range: 1...20), imageURL: "https://example.com/image.png", text: String.randomString(range: 1...200))
        let videoContent = APIMessageResponse.Content.Video(autoplay: Bool.random(), autoplayCellular: Bool.random(), height: Double.random(in: 1...1000), iconURL: "https://example.com/image.png", muted: Bool.random(), url: "https://example.com/video.mp4", width: Double.random(in: 1...1000))
        
        let contentType: Message.ContentType
        if let specifiedType = type {
            contentType = specifiedType
        } else {
            contentType = Message.ContentType.allCases.randomElement()!
        }
        let content: APIMessageResponse.Content
        switch contentType {
            case .html:
                content = .html(htmlContent)
            case .image:
                content = .image(imageContent)
            case .text:
                content = .text(textContent)
            case .video:
                content = .video(videoContent)
        }
        
        return APIMessageResponse(id: Int64.random(in: 1...100000),
                                  action: actionLink,
                                  clicked: Bool.random(),
                                  content: content,
                                  contentType: contentType,
                                  event: String.randomString(range: 1...30),
                                  messageTypes: ["home_nudge"],
                                  persists: Bool.random(),
                                  placement: Int64.random(in: 1...1000),
                                  read: Bool.random(),
                                  title: String.randomString(range: 1...100),
                                  userEventID: Int64.random(in: 1...100000))
    }
    
}
