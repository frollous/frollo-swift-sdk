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

/// Managed all aspects of Payments
public class Payments: ResponseHandler {
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let paymentDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
    }
    
    // MARK: - Make Payments
    
    /**
     Pay Anyone
     
     - parameters:
         - accountHolder: Name of the payee's bank account
         - accountNumber: Account number of the payee
         - amount: Amount of the payment
         - bsb: BSB of payee's bank
         - description: desctiption of the payment (Optional)
         - paymentDate: Date of the payment (Optional)
         - reference: reference of the payment (Optional)
         - sourceAccountId: Account ID of the payment source account
         - completion: Optional completion handler with `APIPayAnyoneResponse` result if succeeds and error if the request fails
     */
    public func payAnyone(accountHolder: String, accountNumber: String, amount: Decimal, bsb: String, description: String? = nil, paymentDate: Date? = nil, reference: String? = nil, sourceAccountId: Int64, completion: @escaping (Result<PayAnyoneResponse, Error>) -> Void) {
        
        let paymentAmount = amount as NSDecimalNumber
        var date: String?
        if let paymentDate = paymentDate {
            date = Payments.paymentDateFormatter.string(from: paymentDate)
        }
        
        let request = APIPayAnyoneRequest(accountHolder: accountHolder, accountNumber: accountNumber, amount: paymentAmount.stringValue, bsb: bsb, description: description, paymentDate: date, reference: reference, sourceAccountId: sourceAccountId)
        
        service.payAnyone(request: request) { result in
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
