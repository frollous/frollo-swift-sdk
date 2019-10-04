//
//  Copyright © 2018 Frollo. All rights reserved.
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

import CoreData
import Foundation

/**
 PayDays
 
 Management of the user's payday
 */
public class PayDays {
    
    /// Notification fired when pay day cache has been updated
    public static let payDayUpdatedNotification = Notification.Name("FrolloSDK.payDays.payDayUpdatedNotification")
    
    private let database: Database
    private let service: APIService
    
    private let payDayLock = NSLock()
    
    init(database: Database, service: APIService) {
        self.database = database
        self.service = service
    }
    
    // MARK: - Pay Day
    
    /**
     Fetch the first available pay day model from the cache
     
     - Returns: Pay day object if found
     */
    
    public func payDay(context: NSManagedObjectContext) -> PayDay? {
        var payDay: PayDay?
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PayDay> = PayDay.fetchRequest()
            
            do {
                let fetchedPayDays = try context.fetch(fetchRequest)
                
                payDay = fetchedPayDays.first
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
        return payDay
    }
    
    /**
     Refresh the user's pay day
     
     Refreshes the latest pay day details for the user.
     
     - parameters:
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process. (Optional)
     */
    public func refreshPayDay(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchPayDay { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handlePayDayResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update Pay Day
     
     Updates the user's pay day on the host
     
     - parameters:
        - period: Period the user is paid over
        - nextDate: Next day the user is paid
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process. (Optional)
     */
    public func updatePayDay(period: PayDay.Period, nextDate: Date, completion: FrolloSDKCompletionHandler? = nil) {
        let dateString = PayDay.payDayDateFormatter.string(from: nextDate)
        
        let request = APIPayDayRequest(frequency: period, nextTransactionDate: dateString)
        
        service.updatePayDay(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handlePayDayResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handlePayDayResponse(_ payDayResponse: APIPayDayResponse, managedObjectContext: NSManagedObjectContext) {
        payDayLock.lock()
        
        defer {
            payDayLock.unlock()
        }
        
        managedObjectContext.performAndWait {
            let fetchRequest: NSFetchRequest<PayDay> = PayDay.fetchRequest()
            
            do {
                let fetchedPayDays = try managedObjectContext.fetch(fetchRequest)
                
                let payDay: PayDay
                if let fetchedPayDay = fetchedPayDays.first {
                    payDay = fetchedPayDay
                } else {
                    payDay = PayDay(context: managedObjectContext)
                }
                
                payDay.update(response: payDayResponse)
                
                do {
                    try managedObjectContext.save()
                } catch {
                    Log.error(error.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: PayDays.payDayUpdatedNotification, object: payDay)
                }
            } catch let error as NSError {
                Log.error(error.localizedDescription)
                
                if error.domain == NSCocoaErrorDomain, error.code == 256, let sqliteError = error.userInfo[NSSQLiteErrorDomain] as? NSNumber, sqliteError.int32Value == 1 {
                    Log.error("Critical database error, corrupted.")
                }
            }
        }
    }
    
}
