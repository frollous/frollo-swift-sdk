//
//  Result.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 18/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

public enum EmptyResult<Failure> {
    case success
    case failure(Failure)
}

public enum Result<Success, Failure> {
    case success(Success)
    case failure(Failure)
}
