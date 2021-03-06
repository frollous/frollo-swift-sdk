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

import XCTest
@testable import FrolloSDK

import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

class SurveysTests: XCTestCase, KeychainServiceIdentifying {

    let keychainService = "SurveysTests"
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testFetchSurvey() {
        let expectation1 = expectation(description: "Network Request 1")
        let surveyKey = "FINANCIAL_WELLBEING"
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + SurveysEndpoint.survey(key: surveyKey).path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "survey_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let surveys = Surveys(service: service)
        surveys.fetchSurvey(surveyKey: surveyKey) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let survey):
                    XCTAssertEqual(survey.key, surveyKey)
                    XCTAssertEqual(survey.displayText, "Survey display text")
                    XCTAssertEqual(survey.iconURL, "https://www.frollo.us/images/survey/1/icon_url.png")
                    XCTAssertEqual(survey.questions.count, 2)
                    XCTAssertEqual(survey.metadata, ["additional_text":"Additional text", "is_optional": false])
                    XCTAssertEqual(survey.metadata?["additional_text"].string, "Additional text")
                    XCTAssertEqual(survey.metadata?["is_optional"].bool, false)
                    XCTAssertEqual(survey.questions[0].type, Survey.Question.QuestionType.slider)
                    XCTAssertEqual(survey.questions[0].id, 1)
                    XCTAssertEqual(survey.questions[0].answers.count, 1)
                    XCTAssertEqual(survey.questions[0].metadata, ["additional_text":"Additional question text", "is_optional": true])
                    XCTAssertEqual(survey.questions[0].metadata?["additional_text"].string, "Additional question text")
                    XCTAssertEqual(survey.questions[0].metadata?["is_optional"].bool, true)
            }
            expectation1.fulfill()
        }
        
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testFetchSurveyFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        let surveyKey = "FINANCIAL_WELLBEING"
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + SurveysEndpoint.survey(key: surveyKey).path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "survey_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let surveys = Surveys(service: service)
        
        surveys.fetchSurvey(surveyKey: surveyKey, latest: true) { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("User logged out, request should fail")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testSubmitSurvey() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + SurveysEndpoint.surveys.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "submit_survey_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let surveys = Surveys(service: service)
        let testSurvey = Survey.createTestSurvey()
        surveys.submitSurvey(survey: testSurvey!) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let survey):
                    XCTAssertEqual(survey.key, testSurvey!.key)
                    XCTAssertEqual(survey.questions.count, 1)
                    XCTAssertEqual(survey.questions[0].id, 1)
                    XCTAssertEqual(survey.questions[0].answers.count, 2)
                    XCTAssertEqual(survey.questions[0].answers[0].id, 1)
                    XCTAssertEqual(survey.questions[0].answers[0].answerType, Survey.Question.Answer.AnswerType.selection)
                    XCTAssertEqual(survey.questions[0].answers[1].answerType, Survey.Question.Answer.AnswerType.freeform)
                
                    XCTAssertEqual(survey.metadata, testSurvey?.metadata)
                    XCTAssertEqual(survey.questions[0].metadata, testSurvey?.questions[0].metadata)
                    XCTAssertEqual(survey.questions[0].metadata?["additional_text"].string, testSurvey?.questions[0].metadata?["additional_text"].string)
                    XCTAssertEqual(survey.questions[0].metadata?["is_optional"].bool, testSurvey?.questions[0].metadata?["is_optional"].bool)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testSubmitSurveyEncodeFail() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + SurveysEndpoint.surveys.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "submit_survey_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let service = invalidService(keychain: Keychain(service: keychainService))
        
        let surveys = Surveys(service: service)
        let testSurvey = Survey.createTestSurvey()
        surveys.submitSurvey(survey: testSurvey!) { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let dataError = error as? DataError {
                        XCTAssertEqual(dataError.type, .api)
                        XCTAssertEqual(dataError.subType, .invalidData)
                    } else {
                        XCTFail("Wrong error returned")
                    }
                case .success:
                    XCTFail("Invalid data should fail")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testSubmitSurveyFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + SurveysEndpoint.surveys.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "submit_survey_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let surveys = Surveys(service: service)
        let testSurvey = Survey.createTestSurvey()
        surveys.submitSurvey(survey: testSurvey!) { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("User logged out, request should fail")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
}


extension Survey {
    static func createTestSurvey() -> Survey?{
        let answer = Question.Answer(id: 0, title: nil, displayText: nil, iconURL: nil, value: "1", selected: true, answerType : Question.Answer.AnswerType.selection)
        let question = Question(id: 1, type: Survey.Question.QuestionType.multipleChoice, title: "", displayText: nil, iconURL: nil, questionOptional: nil, answers: [answer], metadata: ["additional_text":"Additional question text", "is_optional": true])
        
        return Survey(id: 3, key: "FINANCIAL_WELLBEING", name: "Wellbeing Survey", questions: [question], displayText: "Survey display text", iconURL: "https://www.frollo.us/images/survey/1/icon_url.png", metadata: ["additional_text":"Additional text", "is_optional": false])
    }
}
