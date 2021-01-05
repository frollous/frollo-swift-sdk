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

/// Managed all aspects of Cards
public class Cards: ResponseHandler {
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
    }
    
    /// Creates/ Orders a new card on the host.
    /// - Parameters:
    ///   - accountID: ID of the account to which the card is to be linked
    ///   - firstName: First name of the card holder
    ///   - middleName: Middle name of the card holder; Optional
    ///   - lastName: Last name of the card holder
    ///   - postalAddressLine1: Line 1 of the postal address to which the card is to be sent
    ///   - postalAddressLine2: Line 2 of the postal address to which the card is to be sent; Optional
    ///   - postalAddressSuburb: Suburb of the postal address to which the card is to be sent
    ///   - postalCode: Postcode of the address to which the card is to be sent
    ///   - postalAddressState: State of the address to which the card is to be sent
    ///   - postalAddressCountry: Country of the address to which the card is to be sent
    ///   - completion:  Optional completion handler with optional error if the request fails
    public func createCard(accountID: Int64, firstName: String, middleName: String? = nil, lastName: String, postalAddressLine1: String, postalAddressLine2: String? = nil, postalAddressSuburb: String, postalCode: String, postalAddressState: String, postalAddressCountry: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let address = APICreateCardRequest.Address(line1: postalAddressLine1, line2: postalAddressLine2, postcode: postalCode, suburb: postalAddressSuburb, state: postalAddressState, country: postalAddressCountry)
        let request = APICreateCardRequest(accountID: accountID, firstName: firstName, middleName: middleName, lastName: lastName, address: address)
        
        service.createCard(request: request) { result in
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
