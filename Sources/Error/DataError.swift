//
//  DataError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class DataError: FrolloSDKError {
    
    enum DataErrorType {
        case database
        case  unknown
    }
    
    enum DataErrorSubType {
        case diskFull
        
        case unknown
    }
    
    public var type: DataErrorType
    public var subType: DataErrorSubType
    
    public var debugDescription: String {
        get {
            return localizedDescription
        }
    }
    public var localizedDescription: String {
        get {
            return localizedDataErrorDescription()
        }
    }
    
    init(type: DataErrorType, subType: DataErrorSubType) {
        self.type = type
        self.subType = subType
    }
    
    // MARK: - Error Descriptions
    
    private func localizedDataErrorDescription() -> String {
        switch type {
            case .database:
                switch subType {
                    case .diskFull:
                        return Localization.string("DiskFullError")
                    default:
                        return "Unknown Database Error"
                }
            case .unknown:
                switch subType {
                    case .unknown:
                        return Localization.string("UnknownError")
                    default:
                        return Localization.string("UnknownError")
                }
        }
    }
    
    
    
}
