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
        super.setUp()
        
        budgets = Budgets(database: database)
    }
    
    override func tearDown() {
        
    }
    
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
                testBudget1.trackingType = .credit
                testBudget1.trackingStatus = .ahead
                testBudget1.isCurrent = true
                
                let testBudget2 = Budget(context: managedObjectContext)
                testBudget2.populateTestData()
                testBudget2.frequency = .monthly
                testBudget2.status = .active
                testBudget2.trackingType = .debitCredit
                testBudget2.trackingStatus = .behind
                testBudget2.isCurrent = false
                
                let testBudget3 = Budget(context: managedObjectContext)
                testBudget3.populateTestData()
                testBudget3.frequency = .weekly
                testBudget3.status = .failed
                testBudget3.trackingType = .credit
                testBudget3.trackingStatus = .ahead
                testBudget3.isCurrent = true
                
                try! managedObjectContext.save()
            }
            
            let fetchedGoals = self.budgets.budgets(context: self.database.viewContext, current: false, frequency: .monthly, status: .active, trackingStatus: .behind, trackingType: .debitCredit)
            
            XCTAssertNotNil(fetchedGoals)
            XCTAssertEqual(fetchedGoals?.count, 1)
            
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
            
            
            let predicate = NSPredicate(format: #keyPath(Goal.frequencyRawValue) + " == %@", argumentArray: [Budget.Frequency.daily.rawValue])
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
                testBudget1.trackingType = .credit
                
                let testBudget2 = Budget(context: managedObjectContext)
                testBudget2.populateTestData()
                testBudget2.isCurrent = true
                testBudget2.frequency = .monthly
                testBudget2.status = .active
                testBudget2.trackingStatus = .onTrack
                testBudget2.trackingType = .credit
                
                let testBudget3 = Budget(context: managedObjectContext)
                testBudget3.populateTestData()
                testBudget3.isCurrent = true
                testBudget3.frequency = .annually
                testBudget3.status = .completed
                testBudget3.trackingStatus = .ahead
                testBudget3.trackingType = .debit
                
                try! managedObjectContext.save()
            }
            
            let fetchedResultsController = self.budgets.budgetsFetchedResultsController(context: self.database.viewContext, current: true, frequency: .annually, status: .completed, trackingStatus: .ahead, trackingType: .debit)
            
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
    
    // MARK: - Budget Periods
    
    func testFetchGoalPeriodByID() {
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
    
    func testFetchGoalPeriods() {
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
    
    func testGoalPeriodsFetchedResultsController() {
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
            
            
            let predicate = NSPredicate(format: #keyPath(GoalPeriod.trackingStatusRawValue) + " == %@", argumentArray: [Budget.TrackingStatus.onTrack.rawValue])
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
}
