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

/// Manages surveys
public class Surveys: ResponseHandler {
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
    }
    
    /**
     Get a specific survey by key from the host
     
     - parameters:
     - surveyKey: key of the survey to fetch
     - latest: Optional parameter to fetch latest published survey if true. By default false.
     - completion: Completion handler with optional error if the request fails and survey model if succeeds
     */
    
    public func fetchSurvey(surveyKey: String, latest: Bool = false, completion: @escaping (Result<Survey, Error>) -> Void) {
        service.fetchSurvey(surveyKey: surveyKey, latest: latest) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
            
        }
    }
    
    /**
     Submit survey answer
     
     - parameters:
     - survey: answered survey
     - completion: Optional completion handler with optional error if the request fails and survey model if succeeds
     */
    
    public func submitSurvey(survey: Survey, completion: @escaping (Result<Survey, Error>) -> Void) {
        service.submitSurvey(request: survey) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
        
    }
    
}
