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

public class Challenge: NSManagedObject, UniqueManagedObject {
    
    public enum ChallengeType: String, Codable, CaseIterable {
        case merchant
        case transactionCategory = "transaction_category"
    }
    
    public enum Frequency: String, Codable, CaseIterable {
        case monthly
        case weekly
    }
    
    public enum Source: String, Codable, CaseIterable {
        case custom
        case suggested
        case trending
    }
    
    /// Core Data entity description name
    static var entityName = "Challenge"
    
    internal static var primaryKey = #keyPath(Challenge.challengeID)
    
    internal var primaryID: Int64 {
        return challengeID
    }
    
    public var challengeType: ChallengeType {
        get {
            return ChallengeType(rawValue: challengeTypeRawValue)!
        }
        set {
            challengeTypeRawValue = newValue.rawValue
        }
    }
    
    public var frequency: Frequency {
        get {
            return Frequency(rawValue: frequencyRawValue)!
        }
        set {
            frequencyRawValue = newValue.rawValue
        }
    }
    
    /// URL to the large logo image of the goal (optional)
    public var largeLogoURL: URL? {
        get {
            if let urlString = largeLogoURLString {
                return URL(string: urlString)
            }
            return nil
        }
        set {
            largeLogoURLString = newValue?.absoluteString
        }
    }
    
    /// URL to the small logo image (optional)
    public var smallLogoURL: URL? {
        get {
            if let urlString = smallLogoURLString {
                return URL(string: urlString)
            }
            return nil
        }
        set {
            smallLogoURLString = newValue?.absoluteString
        }
    }
    
    public var source: Source {
        get {
            return Source(rawValue: sourceRawValue)!
        }
        set {
            sourceRawValue = newValue.rawValue
        }
    }
    
    /// Steps to complete challenge
    public var steps: [String]? {
        get {
            if let rawValue = stepsRawValue {
                let steps = try? JSONSerialization.jsonObject(with: rawValue, options: .allowFragments)
                return steps as? [String]
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                do {
                    stepsRawValue = try JSONSerialization.data(withJSONObject: newRawValue, options: [])
                } catch {
                    stepsRawValue = nil
                }
            } else {
                stepsRawValue = nil
            }
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
//        if let userChallenge = object as? UserChallenge {
//            addToUserChallenges(userChallenge)
//        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let challengeResponse = response as? APIChallengeResponse {
            update(response: challengeResponse, context: context)
        }
    }
    
    internal func update(response: APIChallengeResponse, context: NSManagedObjectContext) {
        challengeID = response.id
        activeCount = response.community.activeCount
        averageSavingAmount = Decimal(response.community.averageSavingAmount) as NSDecimalNumber
        challengeType = response.challengeType
        completedCount = response.community.completedCount
        details = response.description
        frequency = response.frequency
        largeLogoURLString = response.largeLogoURL
        name = response.name
        smallLogoURLString = response.smallLogoURL
        source = response.source
        startedCount = response.community.startedCount
        steps = response.steps
    }
    
}
