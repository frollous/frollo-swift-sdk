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
         - before: ID of product to fetch list of products before  (optional); used for pagination
         - after: ID of product to fetch list of products after  (optional); used for pagination
         - size: Batch size of products to returned by API (optional);
         - completion: Completion handler with optional error if the request fails and list of `ManagedProduct`with pangination information if succeeds
     */
    
    public func listAvailableProducts(before: String? = nil, after: String? = nil, size: Int? = nil, completion: PaginatedDataCompletionHandler<ManagedProduct>? = nil) {
        
        service.listAvailableProducts(before: before, after: after, size: size) { result in
            
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion?(.success(PaginationInfoWithData(before: response.paging?.cursors?.before, after: response.paging?.cursors?.after, total: response.paging?.total, data: response.data.elements)))
                    }
            }
        }
    }
    
    /**
     Lists all the products that has been created on the user account
     
     - parameters:
         - before: ID of product to fetch list of products before  (optional); used for pagination
         - after: ID of product to fetch list of products after  (optional); used for pagination
         - size: Batch size of products to returned by API (optional);
         - completion: Completion handler with optional error if the request fails and list of `ManagedProduct`with pangination information if succeeds
     */
    
    public func listManagedProducts(before: String? = nil, after: String? = nil, size: Int? = nil, completion: PaginatedDataCompletionHandler<ManagedProduct>? = nil) {
        
        service.listManagedProducts(before: before, after: after, size: size) { result in
            
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion?(.success(PaginationInfoWithData(before: response.paging?.cursors?.before, after: response.paging?.cursors?.after, total: response.paging?.total, data: response.data.elements)))
                    }
            }
        }
    }
    
    /**
     Creates a managed product using a product from the available products
     
     - parameters:
         - productID: ID of `ManagedProduct` to create
         - acceptedTermsConditionsIDs: Array of  IDs of`TermsConditions` for `ManagedProduct` to create
         - completion: Completion handler with optional error if the request fails and `ManagedProduct` if succeeds
     */
    
    public func createManagedProduct(productID: Int64, acceptedTermsConditionsIDs: [Int64], completion: @escaping (Result<ManagedProduct, Error>) -> Void) {
        
        let request = APIProductCreateRequest(productID: productID, acceptedTermsConditionsIDs: acceptedTermsConditionsIDs)
        
        service.createManagedProduct(request: request) { result in
            
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
