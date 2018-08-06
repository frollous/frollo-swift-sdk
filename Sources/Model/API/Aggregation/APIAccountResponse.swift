//
//  APIAccountResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIAccountResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountName = "account_name"
        case accountStatus = "account_status"
        case accountType = "account_type"
        case amountDue = "amount_due"
        case availableBalance = "available_balance"
        case availableCash = "available_cash"
        case availableCredit = "available_credit"
        case apr
        case balanceDetails = "balance_details"
        case classification
        case container
        case currentBalance = "current_balance"
        case dueDate = "due_date"
        case favourite
        case hidden
        case holderProfile = "holder_profile"
        case id
        case included
        case interestRate = "interest_rate"
        case lastPaymentAmount = "last_payment_amount"
        case lastPaymentDate = "last_payment_date"
        case minimumAmountDue = "minimum_amount_due"
        case nickName = "nick_name"
        case providerAccountID = "provider_account_id"
        case providerName = "provider_name"
        case refreshStatus = "refresh_status"
        case totalCashLimit = "total_cash_limit"
        case totalCreditLine = "total_credit_line"
    }
    
    struct Balance: Codable {
        
        enum CodingKeys: String, CodingKey {
            case amount
            case currency
        }
        
        let amount: String
        let currency: String
        
    }
    
    struct BalanceDetails: Codable {
        
        enum CodingKeys: String, CodingKey {
            case currentDescription = "current_description"
            case tiers
        }
        
        let currentDescription: String
        let tiers: [BalanceTier]
        
    }
    
    struct BalanceTier: Codable {
        
        enum CodingKeys: String, CodingKey {
            case description
            case max
            case min
        }
        
        let description: String
        let min: String
        let max: String
    }
    
    struct HolderProfile: Codable {
        
        enum CodingKeys: String, CodingKey {
            case name
        }
        
        let name: String
    }
    
    struct RefreshStatus: Codable {
        
        enum CodingKeys: String, CodingKey {
            case additionalStatus = "additional_status"
            case lastRefreshed = "last_refreshed"
            case nextRefresh = "next_refresh"
            case status
            case subStatus = "sub_status"
        }
        
        let status: AccountRefreshStatus
        
        var additionalStatus: AccountRefreshAdditionalStatus?
        var lastRefreshed: Date?
        var nextRefresh: Date?
        var subStatus: AccountRefreshSubStatus?
    }
    
    var id: Int64
    let accountName: String
    let accountStatus: Account.AccountStatus
    let accountType: Account.AccountSubType
    let container: Account.AccountType
    let favourite: Bool
    let hidden: Bool
    let included: Bool
    let providerAccountID: Int64
    let providerName: String
    let refreshStatus: RefreshStatus
    
    var amountDue: Balance?
    var apr: String?
    var availableBalance: Balance?
    var availableCash: Balance?
    var availableCredit: Balance?
    var balanceDetails: BalanceDetails?
    var classification: Account.Classification?
    var currentBalance: Balance?
    var dueDate: Date?
    var holderProfile: HolderProfile?
    var interestRate: String?
    var lastPaymentAmount: Balance?
    var lastPaymentDate: Date?
    var minimumAmountDue: Balance?
    var nickName: String?
    var totalCashLimit: Balance?
    var totalCreditLine: Balance?

}
