//
//  PreferencesPersistence.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 23/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

protocol PreferencesPersistence {
    
    subscript(key: String) -> Any? { get set }
    
    func reset()
    func setValue(_ value: Any?, for key: String)
    func synchronise()
    
}
