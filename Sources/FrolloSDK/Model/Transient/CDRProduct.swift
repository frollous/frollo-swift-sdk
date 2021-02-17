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

/**
 Represents the CDRProduct that belongs to a Provider
 */
public struct CDRProduct: Codable {
    
    enum CodingKeys: String, CodingKey {
        case brand
        case brandName = "brand_name"
        case externalID = "external_id"
        case feesURI = "fees_uri"
        case termsURI = "terms_uri"
        case id
        case productDescription = "description"
        case productName = "name"
        case providerCategory = "product_category"
        case providerID = "provider_id"
    }
    
    /**
     Represents the category of a CDRProduct
     */
    public enum CDRProductCategory: String, Codable {
        
        /// Transaction and saving accounts
        case transactionAndSavingAccounts = "TRANS_AND_SAVINGS_ACCOUNTS"
        
        /// Term deposits
        case termDeposits = "TERM_DEPOSITS"
        
        /// Travel cards
        case travelCards = "TRAVEL_CARDS"
        
        /// Regulated trust accounts
        case regulatedTrustAccounts = "REGULATED_TRUST_ACCOUNTS"
        
        /// Residential mortgages
        case residentialMortgages = "RESIDENTIAL_MORTGAGES"
        
        /// Credit and charge cards
        case creditAndChargeCards = "CRED_AND_CHRG_CARDS"
        
        /// Personal loans
        case personalLoans = "PERS_LOANS"
        
        /// Margin loans
        case marginLoans = "MARGIN_LOANS"
        
        /// Leases
        case leases = "LEASES"
        
        /// Trade finance
        case tradeFinance = "TRADE_FINANCE"
        
        /// Overdrafts
        case overdrafts = "OVERDRAFTS"
        
        /// Business loans
        case businessLoans = "BUSINESS_LOANS"
        
    }
    
    /// Brand of the product
    public let brand: String?
    
    /// Brand name of the product
    public let brandName: String?
    
    /// Externam ID of the product
    public let externalID: Int64?
    
    /// Fees URI of the product
    public let feesURI: String?
    
    /// Terms URI of the product
    public let termsURI: String?
    
    /// ID of the product
    public let id: Int64
    
    /// Product Description of the product
    public let productDescription: String?
    
    /// Product Name of the product
    public let productName: String?
    
    /// Product Category of the product
    public let providerCategory: CDRProductCategory?
    
    /// ProviderID that product belongs to
    public let providerID: Int64
    
}
