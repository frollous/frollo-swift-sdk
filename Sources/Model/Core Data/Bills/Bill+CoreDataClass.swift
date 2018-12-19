//
//  Bill+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 18/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

public class Bill: NSManagedObject {
    
    enum BillType: String, Codable, CaseIterable {
        case bill
        case manual
        case repayment
        case subscription
    }
    
    enum Frequency: String, Codable, CaseIterable {
        case annually
        case biannually
        case fortnightly
        case fourWeekly = "four_weekly"
        case irregular
        case monthly
        case quarterly
        case weekly
        case unknown
    }
    
    enum PaymentStatus: String, Codable, CaseIterable {
        case due
        case future
        case overdue
        case paid
    }
    
    enum Status: String, Codable, CaseIterable {
        case confirmed
        case estimated
    }
    

}
