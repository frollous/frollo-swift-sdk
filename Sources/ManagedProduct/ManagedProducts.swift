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
public class ManagedProducts: ResponseHandler {
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
    }
    
    /**
     Lists all the products that are available for creation
     
     - parameters:
     - completion: Completion handler with optional error if the request fails and list of `ManagedProduct` if succeeds
     */
    
    public func listAvailableProducts(completion: @escaping (Result<[ManagedProduct], Error>) -> Void) {
        
        service.listAvailableProducts { result in
            
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
     Lists all the products that have been created on the user account
     
     - parameters:
     - completion: Completion handler with optional error if the request fails and list of `ManagedProduct` if succeeds
     */
    
    public func listManagedProducts(completion: @escaping (Result<[ManagedProduct], Error>) -> Void) {
        
        service.listManagedProducts { result in
            
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
     Creates a managed product using a product from the available products
     
     - parameters:
     - managedProduct: `ManagedProduct` to create
     - completion: Completion handler with optional error if the request fails and `ManagedProduct` if succeeds
     */
    
    public func createManagedProduct(managedProduct: ManagedProduct, completion: @escaping (Result<ManagedProduct, Error>) -> Void) {
        
        service.createManagedProduct(request: managedProduct) { result in
            
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
     Delete a specific `ManagedProduct`  by ID from the host
     
     - parameters:
        - productID: ID of the `ManagedProduct`
        - completion: Optional completion handler with optional error if the request fails
     */
    public func deleteManagedProduct(productID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        
        service.deleteManagedProducts(productID: productID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
}
