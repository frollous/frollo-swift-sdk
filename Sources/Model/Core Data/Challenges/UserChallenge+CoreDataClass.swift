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
//

import CoreData
import Foundation

public class UserChallenge: NSManagedObject, UniqueManagedObject {
    
    public enum Status: String, Codable, CaseIterable {
        case active
        case cancelled
        case completed
        case failed
        case finalising
        case unstarted
    }
    
    /// Core Data entity description name
    static var entityName = "UserChallenge"
    
    internal static var primaryKey = #keyPath(UserChallenge.userChallengeID)
    
    internal var primaryID: Int64 {
        return userChallengeID
    }
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let challengeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    public var endDate: Date {
        get {
            return UserChallenge.challengeDateFormatter.date(from: endDateString)!
        }
        set {
            endDateString = UserChallenge.challengeDateFormatter.string(from: newValue)
        }
    }
    
    public var startDate: Date {
        get {
            return UserChallenge.challengeDateFormatter.date(from: startDateString)!
        }
        set {
            startDateString = UserChallenge.challengeDateFormatter.string(from: newValue)
        }
    }
    
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let userChallengeResponse = response as? APIUserChallengeResponse {
            update(response: userChallengeResponse, context: context)
        }
    }
    
    internal func update(response: APIUserChallengeResponse, context: NSManagedObjectContext) {
        userChallengeID = response.id
        challengeID = response.challengeID
        currency = response.currency
        currentSpendAmount = Decimal(response.currentSpendAmount) as NSDecimalNumber
        endDateString = response.endDate
        previousAmount = Decimal(response.previousAmount) as NSDecimalNumber
        startDateString = response.startDate
        status = response.status
        targetAmount = Decimal(response.targetAmount) as NSDecimalNumber
    }
    
}
