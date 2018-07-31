//
//  Aggregation.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class Aggregation {
    
    private let database: Database
    private let network: Network
    
    internal init(database: Database, network: Network) {
        self.database = database
        self.network = network
    }
    
    // MARK: - Cache
    
    // MARK: - Updating Data
    
    /**
     Refresh all available providers from the host.
     
     Includes beta and supported providers. Unsupported and Disabled providers must be fetched by ID.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
    */
    public func refreshProviders(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchProviders { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let providersResponse = response {
                    self.handleProvidersResponse(providersResponse)
                }
            }
            
            completion?(error)
        }
    }
    
    public func refreshProvider(providerID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        
    }
    
    // MARK: - Response Handling
    
    private func handleProvidersResponse(_ providersResponse: [APIProviderResponse]) {
        
    }
    
}
