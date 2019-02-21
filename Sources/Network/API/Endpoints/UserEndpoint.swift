//
//  UserEndpoint.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

enum UserEndpoint: Endpoint {
    
    internal var path: String {
        get {
            return urlPath()
        }
    }
    
    case details
    case login
    case logout
    case register
    case resetPassword
    case user
    
    private func urlPath() -> String {
        switch self {
            case .details:
                return "user/details"
            case .login:
                return "user/login"
            case .logout:
                return "user/logout"
            case .register:
                return "user/register"
            case .resetPassword:
                return "user/reset"
            case .user:
                return "user"
        }
    }
    
}
