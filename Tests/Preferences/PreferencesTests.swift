//
//  PreferencesTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 23/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class PreferencesTests: XCTestCase {
    
    let keychainService = "PreferencesTestsKeychain"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        Keychain(service: keychainService).removeAll()
    }
    
    func testFeatureFlags() {
        let path = tempFolderPath()
        
        let database = Database(path: path)
        
        let preferences = Preferences(path: path)
        
        let managedObjectContext = database.viewContext
        
        let user = User(context: managedObjectContext)
        user.populateTestData()
        
        user.features = [User.FeatureFlag(enabled: false, feature: .aggregation)]
        
        preferences.refreshFeatures(user: user)
        
        XCTAssertFalse(preferences.featureAggregation)
    }
    
    func testResetPreferences() {
        //let preferences = Preferences()
    }
    
}
