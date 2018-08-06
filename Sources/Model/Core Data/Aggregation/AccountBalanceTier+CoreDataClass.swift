//
//  AccountBalanceTier+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

@objc(AccountBalanceTier)
public class AccountBalanceTier: NSManagedObject {
    
    internal func update(response: APIAccountResponse.BalanceTier) {
        name = response.description
        minimum = NSDecimalNumber(string: response.min)
        maximum = NSDecimalNumber(string: response.max)
    }

}
