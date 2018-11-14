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
    
    static func testCompleteData() -> APIMessageResponse {
        let actionLink = APIMessageResponse.Link(link: "frollo://dashboard", openExternal: Bool.random(), title: String.randomString(range: 1...30))
        let buttonLink = APIMessageResponse.Link(link: "https://example.com", openExternal: Bool.random(), title: String.randomString(range: 1...30))
        
        let htmlContent = APIMessageResponse.Content.HTML(body: "<html></html>")
        let imageContent = APIMessageResponse.Content.Image(height: Double.random(in: 1...1000), url: "https://example.com/image.png", width: Double.random(in: 1...1000))
        let textContent = APIMessageResponse.Content.Text(body: String.randomString(range: 1...200))
        let videoContent = APIMessageResponse.Content.Video(autoplay: Bool.random(), autoplayCellular: Bool.random(), height: Double.random(in: 1...1000), muted: Bool.random(), url: "https://example.com/video.mp4", width: Double.random(in: 1...1000))
        
        let randomContentType = Message.ContentType.allCases.randomElement()!
        let content: APIMessageResponse.Content
        switch randomContentType {
            case .html5:
                content = .html(htmlContent)
            case .textAndImage:
                content = .image(imageContent)
            case .text:
                content = .text(textContent)
            case .video:
                content = .video(videoContent)
        }
        
        return APIMessageResponse(id: Int64.random(in: 1...100000),
                                  action: actionLink,
                                  button: buttonLink,
                                  clicked: Bool.random(),
                                  content: content,
                                  contentType: randomContentType,
                                  designType: Message.Design.allCases.randomElement()!,
                                  footer: String.randomString(range: 1...100),
                                  header: String.randomString(range: 1...100),
                                  event: String.randomString(range: 1...30),
                                  iconURL: "https://example.com/image.png",
                                  messageTypes: [.homeNudge],
                                  persists: Bool.random(),
                                  placement: Int64.random(in: 1...1000),
                                  read: Bool.random(),
                                  title: String.randomString(range: 1...100),
                                  userEventID: Int64.random(in: 1...100000))
    }
    
}
