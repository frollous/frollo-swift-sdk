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

import Alamofire

extension APIService {
    
    // MARK: - Pay Anyone
    
    internal func payAnyone(request: APIPayAnyoneRequest, otp: String?, completion: @escaping RequestCompletion<PayAnyoneResponse>) {
        requestQueue.async {
            let url = URL(string: PaymentsEndpoint.payAnyone.path, relativeTo: self.serverURL)!
            
            guard var urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            if let otp = otp {
                urlRequest.addValue(otp, forHTTPHeaderField: HTTPHeader.otp.rawValue)
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: PayAnyoneResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Payment - Transfer
    
    internal func transfer(request: APIPaymentTransferRequest, otp: String?, completion: @escaping RequestCompletion<PaymentTransferResponse>) {
        requestQueue.async {
            let url = URL(string: PaymentsEndpoint.transfers.path, relativeTo: self.serverURL)!
            
            guard var urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            if let otp = otp {
                urlRequest.addValue(otp, forHTTPHeaderField: HTTPHeader.otp.rawValue)
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: PaymentTransferResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Payment - Bpay
    
    internal func bpayPayment(request: APIBpayPaymentRequest, otp: String?, completion: @escaping RequestCompletion<BpayPaymentResponse>) {
        requestQueue.async {
            let url = URL(string: PaymentsEndpoint.bpay.path, relativeTo: self.serverURL)!
            
            guard var urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            if let otp = otp {
                urlRequest.addValue(otp, forHTTPHeaderField: HTTPHeader.otp.rawValue)
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: BpayPaymentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Verify - Pay Anyone
    
    internal func verifyPayAnyone(request: APIVerifyPayAnyoneRequest, completion: @escaping RequestCompletion<VerifyPayAnyoneResponse>) {
        requestQueue.async {
            let url = URL(string: PaymentsEndpoint.verifyPayAnyone.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: VerifyPayAnyoneResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
}
