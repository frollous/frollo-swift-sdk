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

typealias PaymentDetails = APIContactResponse.ContactDetailsType

/// Manages all aspects of Contacts
public class Contacts: ResponseHandler {
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
    }
    
    public func createPayAnyoneContact(name: String? = nil, nickName: String, description: String? = nil, accountName: String, bsb: String, accountNumber: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.PayAnyone = .init(accountHolder: accountName, bsb: bsb, accountNumber: accountNumber)
        let request = APICreateContactRequest(name: name, nickName: nickName, description: description, type: .payAnyone, details: .payAnyone(paymentDetails))
        
        service.createContact(request: request) { result in
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
    
    public func createBPAYContact(name: String? = nil, nickName: String, description: String? = nil, billerCode: String, crn: String, billerName: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.Biller = .init(billerCode: billerCode, crn: crn, billerName: billerName)
        let request = APICreateContactRequest(name: name, nickName: nickName, description: description, type: .BPAY, details: .BPAY(paymentDetails))
        
        service.createContact(request: request) { result in
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
    
    public func createPayIDContact(name: String? = nil, nickName: String, description: String? = nil, payID: String, payIDName: String, payIDType: PayIDContact.PayIDType, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.PayID = .init(payid: payID, name: payIDName, idType: payIDType)
        let request = APICreateContactRequest(name: name, nickName: nickName, description: description, type: .payID, details: .payID(paymentDetails))
        
        service.createContact(request: request) { result in
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
