//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public struct Survey: Codable {
    // key of the survey. Uniquely identifies a survey.
    public let key: String?
    // Name of the survey.
    public let name: String?
    // List of all questions within a survey.
    public let questions: [SurveyQuestion]?
}

public struct SurveyQuestion: Codable {
    // Unique identifier of the question within a survey.
    public let identifier: String?
    // Type of the question. View will be presented according to the type.
    public let type: String?
    // Title of question to be displayed in view.
    public let title: String?
    // Additional text to give more explanation on question.
    public let displayText: String?
    // Url of survey question icon.
    public let iconURL: String?
    // True if the question is optional.
    public let questionOptional: Bool?
    // List of answers of the survey question.
    public let answers: [SurveyAnswer]?
    
    enum CodingKeys: String, CodingKey {
        case identifier, type, title
        case displayText = "display_text"
        case iconURL = "icon_url"
        case questionOptional = "optional"
        case answers
    }
}

public struct SurveyAnswer: Codable {
    // Unique identifier of the answer.
    public let identifier: String?
    // Title of answer.
    public let title: String?
    // Display text of answer.
    public let displayText: String?
    // Url of answer icon.
    public let iconURL: String?
    // Value of the answer.
    public let value: String?
    // True if answer is selected.
    public let selected: Bool?
    
    enum CodingKeys: String, CodingKey {
        case identifier, title
        case displayText = "display_text"
        case iconURL = "icon_url"
        case value, selected
    }
}
