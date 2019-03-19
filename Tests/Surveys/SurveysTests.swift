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

class SurveysTests: XCTestCase {

    let keychainService = "SurveysTests"
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testFetchSurvey() {
        
        let expectation1 = expectation(description: "Network Request 1")
        let surveyKey = "FINANCIAL_WELLBEING_4"
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + SurveysEndpoint.survey(key: surveyKey).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "survey_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let surveys = Surveys(service: service)
        surveys.fetchSurvey(surveyKey: surveyKey, completion: { (result) in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let survey):
                XCTAssertEqual(survey.key, "FINANCIAL_WELLBEING_4")
                XCTAssertEqual(survey.questions.count, 2)
                XCTAssertEqual(survey.questions[0].type, Survey.Question.QuestionType.multipleChoice)
                XCTAssertEqual(survey.questions[1].id, 4)
                XCTAssertEqual(survey.questions[0].answers.count, 3)
            }
            expectation1.fulfill()
        })
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testSubmitSurvey() {
        
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + SurveysEndpoint.surveys.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "submit_survey_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
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
                XCTAssertEqual(survey.questions[0].answers.count, 1)
                XCTAssertEqual(survey.questions[0].id, 4)
                XCTAssertEqual(survey.questions[0].answers.count, 1)
                XCTAssertEqual(survey.questions[0].answers[0].id, 3)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
}


extension Survey {
    static func createTestSurvey() -> Survey?{
        let answer = Question.Answer(id: 0, title: nil, displayText: nil, iconURL: nil, value: "1", selected: true)
        let question = Question(id: 1, type: Survey.Question.QuestionType.multipleChoice, title: "", displayText: nil, iconURL: nil, questionOptional: nil, answers: [answer])
        
        return Survey(id: 3, key: "FINANCIAL_WELLBEING_4", name: "", questions: [question])
    }
}
