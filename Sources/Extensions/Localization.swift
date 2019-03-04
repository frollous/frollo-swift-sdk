//
//  Localization.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class Localization {
    
    internal static func string(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "Localizable", bundle: Bundle(for: self), value: "", comment: "")
    }
    
}
