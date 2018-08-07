//
//  APIMerchantResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIMerchantResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case merchantType = "merchant_type"
        case name
        case smallLogoURL = "small_logo_url"
    }
    
    var id: Int64
    let merchantType: Merchant.MerchantType
    let name: String
    let smallLogoURL: String
    
}
