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
