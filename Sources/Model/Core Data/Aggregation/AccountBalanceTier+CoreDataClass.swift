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
        minimum = Decimal(response.min) as NSDecimalNumber?
        maximum = Decimal(response.max) as NSDecimalNumber?
    }

}
