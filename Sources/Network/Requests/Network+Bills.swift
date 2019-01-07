//
//  Network+Bills.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 19/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension Network {
    
    // MARK: - Bills
    
    internal func createBill(request: APIBillCreateRequest, completion: @escaping RequestCompletion<APIBillResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bills.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .post, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 201...201).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIBillResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func deleteBill(billID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bill(billID: billID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { (response) in
                self.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBills(completion: @escaping RequestCompletion<[APIBillResponse]>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bills.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleBillsReponse(response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBill(billID: Int64, completion: @escaping RequestCompletion<APIBillResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bill(billID: billID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIBillResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateBill(billID: Int64, request: APIBillUpdateRequest, completion: @escaping RequestCompletion<APIBillResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.bill(billID: billID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .put, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response: DataResponse<Data>) in
                self.handleResponse(type: APIBillResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Bill Payments
    
    internal func deleteBillPayment(billPaymentID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.billPayment(billPaymentID: billPaymentID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { (response) in
                self.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBillPayments(from fromDate: Date, to toDate: Date, completion: @escaping RequestCompletion<[APIBillPaymentResponse]>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.billPayments.path, relativeTo: self.serverURL)!
            
            let dateFormatter = Transaction.transactionDateFormatter
            
            let parameters = [BillsEndpoint.QueryParameters.fromDate.rawValue: dateFormatter.string(from: fromDate),
                              BillsEndpoint.QueryParameters.toDate.rawValue: dateFormatter.string(from: toDate)]
            
            self.sessionManager.request(url, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIBillPaymentResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBillPayment(billPaymentID: Int64, completion: @escaping RequestCompletion<APIBillPaymentResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.billPayment(billPaymentID: billPaymentID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIBillPaymentResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateBillPayment(billPaymentID: Int64, request: APIBillPaymentUpdateRequest, completion: @escaping RequestCompletion<APIBillPaymentResponse>) {
        requestQueue.async {
            let url = URL(string: BillsEndpoint.billPayment(billPaymentID: billPaymentID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .put, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIBillPaymentResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleBillsReponse(response: DataResponse<Data>, completion: RequestCompletion<[APIBillResponse]>) {
        switch response.result {
            case .success(let value):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                do {
                    let billsResponse = try decoder.decode(APIBillsResponse.self, from: value)
                    
                    completion(billsResponse.bills, nil)
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .unknown, subType: .unknown)
                    completion(nil, dataError)
                }
            case .failure:
                self.handleFailure(response: response) { (error) in
                    completion(nil, error)
                }
        }
    }
    
}
