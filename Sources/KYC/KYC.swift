//
//  Copyright © 2019 Frollo. All rights reserved.
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
public class KYC: ResponseHandler {
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
    }
    
    /**
     Get KYC for user from the host
     
     - parameters:
     - completion: Completion handler with optional error if the request fails and survey model if succeeds
     */
    
    public func getKYC(completion: @escaping (Result<UserKYC, Error>) -> Void) {
        
        service.fetchKYC { result in
            
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
     Create KYC for the user
     
     - parameters:
     - userKYC: KYC of the user to create
     - completion: Completion handler with optional error if the request fails and survey model if succeeds
     */
    
    public func createKYC(userKYC: UserKYC, completion: @escaping (Result<UserKYC, Error>) -> Void) {
        
        service.createKYC(request: userKYC) { result in
            
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
     Update the KYC of user
     
     - parameters:
     - userKYC: KYC of the user to update
     - completion: Completion handler with optional error if the request fails and userKYC model if succeeds
     */
    
    public func updateKYC(userKYC: UserKYC, completion: @escaping (Result<UserKYC, Error>) -> Void) {
        
        service.createKYC(request: userKYC) { result in
            
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
     Get KYC status for user from the host
     
     - parameters:
     - completion: Completion handler with optional error if the request fails and KYC status if succeeds
     */
    
    public func getKYCStatus(completion: @escaping (Result<UserKYCStatus, Error>) -> Void) {
        
        service.getKYCStatus { result in
            
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
     Update KYC status for the user
     
     - parameters:
     - status: status of user KYC
     - completion: Completion handler with optional error if the request fails and survey model if succeeds
     */
    
    public func updateKYCStatus(status: UserKYCStatus, completion: @escaping (Result<UserKYCStatus, Error>) -> Void) {
        
        service.sendKYCStatus(request: status) { result in
            
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
