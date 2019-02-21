//
//  HTTPHeader.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

internal enum HTTPHeader: String, CaseIterable {
    case apiVersion = "X-Api-Version"
    case authorization = "Authorization"
    case background = "X-Background"
    case bundleID = "X-Bundle-Id"
    case contentType = "Content-Type"
    case deviceVersion = "X-Device-Version"
    case etag = "Etag"
    case softwareVersion = "X-Software-Version"
    case userAgent = "User-Agent"
}
