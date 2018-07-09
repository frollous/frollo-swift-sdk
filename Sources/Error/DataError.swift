//
//  DataError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class DataError: FrolloSDKError {
    
    enum DataErrorType: String {
        case database
        case unknown
    }
    
    enum DataErrorSubType: String {
        case corrupt
        case diskFull
        case migrationFailed
        
        case unknown
    }
    
    public var type: DataErrorType
    public var subType: DataErrorSubType
    
    public var debugDescription: String {
        get {
            return debugDataErrorDescription()
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
                    case .corrupt:
                        return Localization.string("Error.Data.Database.Corrupted")
                    case .diskFull:
                        return Localization.string("Error.Data.Database.DiskFullError")
                    case .migrationFailed:
                        return Localization.string("Error.Data.Database.MigrationFailed")
                    default:
                        return Localization.string("Error.Data.Database.UnknownError")
                }
            case .unknown:
                switch subType {
                    case .unknown:
                        return Localization.string("Error.Generic.UnknownError")
                    default:
                        return Localization.string("Error.Generic.UnknownError")
                }
        }
    }
    
    private func debugDataErrorDescription() -> String {
        return "DataError: " + type.rawValue + "." + subType.rawValue + ": " + localizedDescription
    }
    
}
