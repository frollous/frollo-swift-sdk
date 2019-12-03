//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CoreData
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class BudgetsTests: BaseTestCase {
    
    override func setUp() {
        testsKeychainService = "BudgetsTests"
        super.setUp()
        
        let keychain = defaultKeychain(isNetwork: true)
        
        let authentication = defaultAuthentication(keychain: keychain)
        let network = defaultNetwork(keychain: keychain, authentication: authentication)
        let service = defaultService(keychain: keychain, authentication: authentication)
        
        let authService = defaultAuthService(keychain: keychain, network: network)
        
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        aggregation = Aggregation(database: database, service: service)
        
        budgets = Budgets(database: database, service: service)
        
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    var aggregation: Aggregation!
    var budgets: Budgets!
    
    // MARK: - Budgets
    
    func testFetchBudgetByID() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testBudget = Budget(context: managedObjectContext)
                testBudget.populateTestData()
                testBudget.budgetID = id
                
                try! managedObjectContext.save()
            }
            
            
            let budget = self.budgets.budget(context: self.database.viewContext, budgetID: id)
            
            XCTAssertNotNil(budget)
            XCTAssertEqual(budget?.budgetID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBudgets() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBudget1 = Budget(context: managedObjectContext)
                testBudget1.populateTestData()
                testBudget1.status = .active
                testBudget1.isCurrent = true
                
                let testBudget2 = Budget(context: managedObjectContext)
                testBudget2.populateTestData()
                testBudget2.status = .active
                testBudget2.isCurrent = true
                
                let testBudget3 = Budget(context: managedObjectContext)
                testBudget3.populateTestData()
                testBudget3.status = .active
                testBudget3.isCurrent = true
                
                try! managedObjectContext.save()
            }
            
            
            let predicate = NSPredicate(format: #keyPath(Budget.statusRawValue) + " == %@", argumentArray: [Budget.Status.active.rawValue])
            let fetchedBudgets = self.budgets.budgets(context: self.database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedBudgets)
            XCTAssertEqual(fetchedBudgets?.count, 3)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchFilteredBudgets() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBudget1 = Budget(context: managedObjectContext)
                testBudget1.populateTestData()
                testBudget1.frequency = .weekly
                testBudget1.status = .failed
                testBudget1.budgetType = .merchant
                testBudget1.trackingStatus = .ahead
                testBudget1.isCurrent = true
                
                let testBudget2 = Budget(context: managedObjectContext)
                testBudget2.populateTestData()
                testBudget2.frequency = .monthly
                testBudget2.status = .active
                testBudget2.budgetType = .category
                testBudget2.trackingStatus = .behind
                testBudget2.isCurrent = false
                
                let testBudget3 = Budget(context: managedObjectContext)
                testBudget3.populateTestData()
                testBudget3.frequency = .weekly
                testBudget3.status = .failed
                testBudget3.budgetType = .budgetCategory
                testBudget3.trackingStatus = .ahead
                testBudget3.isCurrent = true
                
                try! managedObjectContext.save()
            }
            
            let fetchedBudgets = self.budgets.budgets(context: self.database.viewContext, current: false, budgetType: .category, frequency: .monthly, status: .active, trackingStatus: .behind)
            
            XCTAssertNotNil(fetchedBudgets)
            XCTAssertEqual(fetchedBudgets?.count, 1)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testBudgetsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBudget1 = Budget(context: managedObjectContext)
                testBudget1.populateTestData()
                testBudget1.frequency = .weekly
                testBudget1.isCurrent = true
                
                let testBudget2 = Budget(context: managedObjectContext)
                testBudget2.populateTestData()
                testBudget2.frequency = .daily
                testBudget2.isCurrent = true
                
                let testBudget3 = Budget(context: managedObjectContext)
                testBudget3.populateTestData()
                testBudget3.frequency = .daily
                testBudget3.isCurrent = true
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: #keyPath(Budget.frequencyRawValue) + " == %@", argumentArray: [Budget.Frequency.daily.rawValue])
            let fetchedResultsController = self.budgets.budgetsFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFilteredBudgetsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBudget1 = Budget(context: managedObjectContext)
                testBudget1.populateTestData()
                testBudget1.isCurrent = true
                testBudget1.frequency = .monthly
                testBudget1.status = .active
                testBudget1.trackingStatus = .onTrack
                testBudget1.budgetType = .category
                
                let testBudget2 = Budget(context: managedObjectContext)
                testBudget2.populateTestData()
                testBudget2.isCurrent = true
                testBudget2.frequency = .monthly
                testBudget2.status = .active
                testBudget2.trackingStatus = .onTrack
                testBudget2.budgetType = .category
                
                let testBudget3 = Budget(context: managedObjectContext)
                testBudget3.populateTestData()
                testBudget3.isCurrent = true
                testBudget3.frequency = .annually
                testBudget3.status = .completed
                testBudget3.trackingStatus = .ahead
                testBudget3.budgetType = .category
                
                try! managedObjectContext.save()
            }
            
            let fetchedResultsController = self.budgets.budgetsFetchedResultsController(context: self.database.viewContext, current: true, budgetType: .category, frequency: .annually, status: .completed, trackingStatus: .ahead)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 1)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshBudgetByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: BudgetsEndpoint.budget(budgetID: 4).path.prefixedWithSlash, toResourceWithName: "budget_valid_4")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.budgets.refreshBudget(budgetID: 4) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "budgetID == %ld", argumentArray: [4])
                        
                        do {
                            let fetchedBudgets = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedBudgets.first?.budgetID, 4)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshBudgets() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: BudgetsEndpoint.budgets.path.prefixedWithSlash, toResourceWithName: "budgets_valid")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.budgets.refreshBudgets() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Budget.budgetID), ascending: true)]
                        
                        do {
                            let fetchedBudgets = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedBudgets.count, 3)
                            
                            let budget = fetchedBudgets[0]
                            
                            XCTAssertEqual(budget.budgetID, 4)
                            XCTAssertEqual(budget.isCurrent,true)
                            XCTAssertEqual(budget.currency, "AUD")
                            XCTAssertEqual(budget.currentAmount, 3880.00)
                            XCTAssertEqual(budget.estimatedTargetAmount, 248.33)
                            XCTAssertEqual(budget.frequency, .fourWeekly)
                            XCTAssertEqual(budget.metadata, [:])
                            XCTAssertEqual(budget.periodAmount, 15.38)
                            XCTAssertEqual(budget.periodsCount, 75)
                            XCTAssertEqual(budget.startDateString, "2019-10-02")
                            XCTAssertEqual(budget.status, .active)
                            XCTAssertEqual(budget.typeValue, "lifestyle")
                            XCTAssertEqual(budget.targetAmount, 1000.00)
                            XCTAssertEqual(budget.trackingStatus, .ahead)
                            XCTAssertEqual(budget.budgetType, .category)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
        
    // MARK: - Budget Periods
    
    func testFetchBudgetPeriodByID() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testBudgetPeriod = BudgetPeriod(context: managedObjectContext)
                testBudgetPeriod.populateTestData()
                testBudgetPeriod.budgetPeriodID = id
                
                try! managedObjectContext.save()
            }
            
            
            let budgetPeriod = self.budgets.budgetPeriod(context: self.database.viewContext, budgetPeriodID: id)
            
            XCTAssertNotNil(budgetPeriod)
            XCTAssertEqual(budgetPeriod?.budgetPeriodID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBudgetPeriods() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBudgetPeriod1 = BudgetPeriod(context: managedObjectContext)
                testBudgetPeriod1.populateTestData()
                testBudgetPeriod1.trackingStatus = .behind
                
                let testBudgetPeriod2 = BudgetPeriod(context: managedObjectContext)
                testBudgetPeriod2.populateTestData()
                testBudgetPeriod2.trackingStatus = .ahead
                
                let testBudgetPeriod3 = BudgetPeriod(context: managedObjectContext)
                testBudgetPeriod3.populateTestData()
                testBudgetPeriod3.trackingStatus = .behind
                
                try! managedObjectContext.save()
            }
            
            
            let predicate = NSPredicate(format: #keyPath(BudgetPeriod.trackingStatusRawValue) + " == %@", argumentArray: [Budget.TrackingStatus.behind.rawValue])
            let fetchedBudgetPeriods = self.budgets.budgetPeriods(context: self.database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedBudgetPeriods)
            XCTAssertEqual(fetchedBudgetPeriods?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testBudgetPeriodsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBudgetPeriod1 = BudgetPeriod(context: managedObjectContext)
                testBudgetPeriod1.populateTestData()
                testBudgetPeriod1.trackingStatus = .ahead
                
                let testBudgetPeriod2 = BudgetPeriod(context: managedObjectContext)
                testBudgetPeriod2.populateTestData()
                testBudgetPeriod2.trackingStatus = .onTrack
                
                let testBudgetPeriod3 = BudgetPeriod(context: managedObjectContext)
                testBudgetPeriod3.populateTestData()
                testBudgetPeriod3.trackingStatus = .onTrack
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: #keyPath(BudgetPeriod.trackingStatusRawValue) + " == %@", argumentArray: [Budget.TrackingStatus.onTrack.rawValue])
            let fetchedResultsController = self.budgets.budgetPeriodsFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshBudgetPeriods() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: BudgetsEndpoint.periods(budgetID: 85).path.prefixedWithSlash, toResourceWithName: "budget_periods_valid")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let fromDate = Budget.budgetDateFormatter.date(from: "2019-11-21")!
            let toDate = Budget.budgetDateFormatter.date(from: "2019-12-05")!
            
            self.budgets.refreshBudgetPeriods(budgetID: 85, from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<BudgetPeriod> = BudgetPeriod.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(BudgetPeriod.budgetPeriodID), ascending: true)]
                        
                        do {
                            let fetchedBudgetPeriods = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedBudgetPeriods.count, 15)
                            
                            if let budgetPeriod = fetchedBudgetPeriods.first {
                                XCTAssertEqual(budgetPeriod.budgetPeriodID, 85)
                                XCTAssertEqual(budgetPeriod.budgetID, 4)
                                XCTAssertEqual(budgetPeriod.currentAmount, 111.42)
                                XCTAssertEqual(budgetPeriod.endDateString, "2019-11-22")
                                XCTAssertEqual(budgetPeriod.requiredAmount, 173.5)
                                XCTAssertEqual(budgetPeriod.startDateString, "2019-11-21")
                                XCTAssertEqual(budgetPeriod.targetAmount, 15.62)
                                XCTAssertEqual(budgetPeriod.trackingStatus, .behind)
                                XCTAssertEqual(budgetPeriod.index, 50)
                            } else {
                                XCTFail("Budget Period missing")
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshBudgetPeriod() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: BudgetsEndpoint.period(budgetID: 4, budgetPeriodID: 96).path.prefixedWithSlash, toResourceWithName: "budget_periods_96")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.budgets.refreshBudgetPeriod(budgetID: 4, budgetPeriodID: 96) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<BudgetPeriod> = BudgetPeriod.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "budgetPeriodID == %ld", argumentArray: [96])
                        
                        do {
                            let fetchedBudgetPeriods = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedBudgetPeriods.first?.budgetPeriodID, 96)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
}
