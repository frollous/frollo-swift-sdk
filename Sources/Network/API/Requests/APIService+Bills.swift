//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

import Alamofire

extension APIService {
    
    // MARK: - Bills
    
    internal func createBill(request: APIBillCreateRequest, completion: @escaping RequestCompletion<APIBillResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bills.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIBillResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func deleteBill(billID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bill(billID: billID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBills(completion: @escaping RequestCompletion<[APIBillResponse]>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bills.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.handleBillsReponse(response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBill(billID: Int64, completion: @escaping RequestCompletion<APIBillResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bill(billID: billID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIBillResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateBill(billID: Int64, request: APIBillUpdateRequest, completion: @escaping RequestCompletion<APIBillResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bill(billID: billID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { (response: AFDataResponse<Data>) in
                self.network.handleResponse(type: APIBillResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Bill Payments
    
    internal func deleteBillPayment(billPaymentID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.billPayment(billPaymentID: billPaymentID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBillPayments(from fromDate: Date, to toDate: Date, completion: @escaping RequestCompletion<[APIBillPaymentResponse]>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.billPayments.path, relativeTo: self.serverURL)!
            
            let dateFormatter = Transaction.transactionDateFormatter
            
            let parameters = [BillsEndpoint.QueryParameters.fromDate.rawValue: dateFormatter.string(from: fromDate),
                              BillsEndpoint.QueryParameters.toDate.rawValue: dateFormatter.string(from: toDate)]
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIBillPaymentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBillPayment(billPaymentID: Int64, completion: @escaping RequestCompletion<APIBillPaymentResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.billPayment(billPaymentID: billPaymentID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIBillPaymentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateBillPayment(billPaymentID: Int64, request: APIBillPaymentUpdateRequest, completion: @escaping RequestCompletion<APIBillPaymentResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.billPayment(billPaymentID: billPaymentID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIBillPaymentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleBillsReponse(response: AFDataResponse<Data>, completion: RequestCompletion<[APIBillResponse]>) {
        switch response.result {
            case .success(let value):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                do {
                    let billsResponse = try decoder.decode(APIBillsResponse.self, from: value)
                    
                    completion(.success(billsResponse.bills))
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .unknown, subType: .unknown)
                    completion(.failure(dataError))
                }
            case .failure(let error):
                network.handleFailure(type: APIError.self, response: response, error: error) { error in
                    completion(.failure(error))
                }
        }
    }
    
}
