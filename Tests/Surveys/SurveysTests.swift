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
        let testSurvey = Survey.createTestSurvey()
        surveys.fetchSurvey(surveyKey: surveyKey, completion: { (result) in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let survey):
                XCTAssertEqual(survey.key, testSurvey!.key)
                XCTAssertEqual(survey.questions?.count, 2)
                XCTAssertEqual(survey.questions?[0].type, SurveyQuestion.QuestionType.multipleChoice)
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
                XCTAssertEqual(survey.questions?.count, 1)
                XCTAssertEqual(survey.questions?[0].answers?.count, 1)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    
}


extension Survey{
    
    static func createTestSurvey() -> Survey?{
        let jsonString = "{\"id\": 4,\"key\": \"FINANCIAL_WELLBEING_4\",\"name\": \"Wellbeing Survey\",\"questions\": [{\"id\": 4,\"type\": \"multiple_choice\",\"title\": \"How do you feel about your finances?\",\"display_text\": \"This let' us understand the level of support we should give you to keep you on the right track.\",\"answers\": [{\"id\": 12,\"title\": \"NEEDS FIXING\",\"display_text\": \"Always feel overwhelmed and I am always worried about money.\",\"value\": \"1\",\"selected\": false},{\"id\": 13,\"title\": \"NOT GREAT\",\"display_text\": \"Often feel overwhelmed and I worry about my money.\",\"value\": \"2\",\"selected\": false},{\"id\": 14,\"title\": \"OK\",\"display_text\": \"I know enough but need to put things into practice. Sometimes I worry about money.\",\"value\": \"3\",\"selected\": false},{\"id\": 15,\"title\": \"GOOD\",\"display_text\": \"I feel comfortable about my money situations and rarely I worry about money.\",\"value\": \"4\",\"selected\": false},{\"id\": 16,\"title\": \"GREAT\",\"display_text\": \"Have mastered my finance and never worry about money.\",\"value\": \"5\",\"selected\": true}]},{\"id\": 3,\"type\": \"slider\",\"title\": \"Frollo is here to help you!\",\"display_text\": \"We aim to personalise every experience. So we can provide you with meaningful financial direction, please let us know why you are here. I am here to...\",\"answers\": [{\"id\": 9,\"display_text\": \"Save for a goal\",\"value\": \"1\",\"selected\": true},{\"id\": 10,\"display_text\": \"Find out where my money goes\",\"value\": \"2\",\"selected\": false},{\"id\": 11,\"display_text\": \"Get support in paying off debt\",\"value\": \"3\",\"selected\": false}]}]}"
        
        if let jsonData = jsonString.data(using: .utf8)
        {
            let survey = try? JSONDecoder().decode(Survey.self, from: jsonData)
            return survey
        }
        return nil
        
    }
}
