//
//  Result.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 18/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

/// A value that represents either a success or a failure, including an associated error on failure.
public enum EmptyResult<Failure> {
    
    /// A success
    case success
    
    /// A failure, storing a `Failure` value.
    case failure(Failure)
    
}

/// A value that represents either a success or a failure, including an associated value in each case.
public enum Result<Success, Failure> {
    
    /// A success, storing a `Success` value.
    case success(Success)
    
    /// A failure, storing a `Failure` value.
    case failure(Failure)
    
}
