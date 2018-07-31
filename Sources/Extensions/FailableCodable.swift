//
//  FailableCodable.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

internal struct FailableDecodable<Base: Decodable>: Decodable {
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

/**
 Failable Codable Array
 
 Allows iterating through a Decodable array and handling invalid objects without dropping the entire data set
 */
internal struct FailableCodableArray<Element: Decodable>: Decodable {
    
    private(set) var elements: [Element]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        
        while !container.isAtEnd {
            guard let element = try container.decode(FailableDecodable<Element>.self).base else {
                continue
            }
            
            elements.append(element)
        }
        
        self.elements = elements
    }
    
}
