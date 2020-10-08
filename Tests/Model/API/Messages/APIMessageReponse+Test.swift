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

import Foundation
@testable import FrolloSDK

extension APIMessageResponse {
    
    static func testCompleteData(type: Message.ContentType? = nil) -> APIMessageResponse {
        let actionLink = APIMessageResponse.Link(link: "frollo://dashboard", openMode: .internalOpen, title: String.randomString(range: 1...30))
        
        let htmlContent = APIMessageResponse.Content.HTML(footer: String.randomString(range: 1...10), header: String.randomString(range: 1...20), main: "<html></html>")
        let imageContent = APIMessageResponse.Content.Image(height: Double.random(in: 1...1000), url: "https://example.com/image.png", width: Double.random(in: 1...1000))
        let textContent = APIMessageResponse.Content.Text(designType: "information", footer: String.randomString(range: 1...20), header: String.randomString(range: 1...20), imageURL: "https://example.com/image.png", text: String.randomString(range: 1...200))
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
                                  content: content,
                                  contentType: contentType,
                                  event: String.randomString(range: 1...30),
                                  interacted: Bool.random(),
                                  metadata: ["field": 1],
                                  messageTypes: ["home_nudge"],
                                  persists: Bool.random(),
                                  placement: Int64.random(in: 1...1000),
                                  read: Bool.random(),
                                  title: String.randomString(range: 1...100),
                                  userEventID: Int64.random(in: 1...100000),
                                  autoDismiss: Bool.random())
        
    }
    
}
