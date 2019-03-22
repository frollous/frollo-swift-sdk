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

/**
 Survey Model
 
 Holds information about the survey, questions and answers
 */
public class Survey: Codable {
    
    /// Id of the survey. Uniquely identifies a survey.
    public let id: Int64
    
    /// Key of the survey. used to fetch a survey.
    public let key: String
    
    /// Name of the survey.
    public let name: String?
    
    /// List of all questions within a survey.
    public let questions: [Question]
    
    ///initilizer
    init(id: Int64, key: String, name: String?, questions: [Question]) {
        self.id = id
        self.key = key
        self.name = name
        self.questions = questions
    }
    
    /**
     Question
     
     Question of a Survey
     */
    public class Question: Codable {
        
        /// Unique identifier of the question within a survey.
        public let id: Int64
        
        /// Type of the question. View will be presented according to the type.
        public let type: QuestionType
        
        /// Title of question to be displayed in view.
        public let title: String
        
        /// Additional text to give more explanation on question.
        public let displayText: String?
        
        /// Url of survey question icon.
        public let iconURL: String?
        
        /// True if the question is optional.
        public let questionOptional: Bool?
        
        /// List of answers of the survey question.
        public var answers: [Answer]
        
        ///initilizer
        init(id: Int64, type: QuestionType, title: String, displayText: String?, iconURL: String?, questionOptional: Bool?, answers: [Answer]) {
            self.id = id
            self.type = type
            self.title = title
            self.displayText = displayText
            self.iconURL = iconURL
            self.questionOptional = questionOptional
            self.answers = answers
        }
        
        private enum CodingKeys: String, CodingKey {
            case id
            case type
            case title
            case displayText = "display_text"
            case iconURL = "icon_url"
            case questionOptional = "optional"
            case answers
        }
        
        /// type of a question
        public enum QuestionType: String, Codable {
            
            /// question with slider view
            case slider
            
            /// question with multiple choice select view
            case multipleChoice = "multiple_choice"
            
            /// question with checkbox view
            case checkbox
            
        }
        
        /**
         Answer
         
         Answer of a Question
         */
        public class Answer: Codable {
            
            /// Unique identifier of the answer.
            public let id: Int64
            
            /// Title of answer.
            public let title: String?
            
            /// Display text of answer.
            public let displayText: String?
            
            /// Url of answer icon.
            public let iconURL: String?
            
            /// Value of the answer.
            public var value: String
            
            /// True if answer is selected.
            public var selected: Bool
            
            /// Type of the answer.
            public var answerType: AnswerType
            
            ///initilizer
            init(id: Int64, title: String?, displayText: String?, iconURL: String?, value: String, selected: Bool, answerType: AnswerType) {
                self.id = id
                self.title = title
                self.displayText = displayText
                self.iconURL = iconURL
                self.value = value
                self.selected = selected
                self.answerType = answerType
            }
            
            private enum CodingKeys: String, CodingKey {
                case id, title
                case displayText = "display_text"
                case iconURL = "icon_url"
                case value, selected
                case answerType = "type"
            }
            
            /// type of an answer
            public enum AnswerType: String, Codable {
                
                /// answer with normal selection
                case normalSelection = "normal_selection"
                
                /// answer with open end
                case openEnded = "open_ended"
                
            }
        }
    }
}
