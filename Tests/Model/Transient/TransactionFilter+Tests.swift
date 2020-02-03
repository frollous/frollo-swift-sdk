//
//  Copyright © 2019 Frollo. All rights reserved.
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

import Foundation
import CoreData
import XCTest
@testable import FrolloSDK

class TransactionFilterTests: BaseTestCase {
    
    var transactionFilter = TransactionFilter()
    
    override func setUp() {
        testsKeychainService = "TransactionFilterTests"
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        Keychain(service: keychainService).removeAll()
    }
    
    func testTransactionFilterURL() {
        transactionFilter.populateTestData()
        
        XCTAssertEqual(transactionFilter.urlString, "aggregation/transactions?account_ids=11,22,33&transaction_ids=66,77,88,99&merchant_ids=23,45,67,78&transaction_category_ids=4546,5767,6883&search_term=Woolies&budget_category=lifestyle,goals&min_amount=22.44&max_amount=66.00&from_date=2019-11-11&to_date=2020-01-29&base_type=credit&transaction_included=false&account_included=true&tags=Frollo%26Volt,Groceries%20Aldi")
    }
    
    func testTransactionFilterPredicates() {
        transactionFilter.populateTestData()
        let predicates = transactionFilter.filterPredicates
           
        XCTAssertEqual(NSCompoundPredicate(andPredicateWithSubpredicates: predicates).predicateFormat, "transactionDateString >= \"2019-11-11\" AND transactionDateString <= \"2020-01-29\" AND transactionID IN {66, 77, 88, 99} AND merchantID IN {23, 45, 67, 78} AND accountID IN {11, 22, 33} AND transactionCategoryID IN {4546, 5767, 6883} AND budgetCategoryRawValue IN {\"lifestyle\", \"goals\"} AND baseTypeRawValue == \"credit\" AND amount >= 22.44 AND amount <= 66 AND (userTagsRawValue CONTAINS[cd] \"Frollo&Volt\" OR userTagsRawValue CONTAINS[cd] \"Groceries Aldi\") AND included == 0 AND account.included == 1 AND (userDescription CONTAINS[cd] \"Woolies\" OR simpleDescription CONTAINS[cd] \"Woolies\" OR originalDescription CONTAINS[cd] \"Woolies\" OR memo CONTAINS[cd] \"Woolies\")")
       }
    
    func testTransactionFilters() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil, handler: nil)
        
        var transactionFilter = TransactionFilter()
        
        connect(endpoint: AggregationEndpoint.transactions(transactionFilter: transactionFilter).path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
                        
            aggregation.refreshTransactions() { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        transactionFilter.budgetCategories = [.living, .lifestyle]
                        var fetchedTransactions = aggregation.transactions(context: context, transactionFilter: transactionFilter)
                        XCTAssertEqual(fetchedTransactions?.count, 33)

                        transactionFilter = TransactionFilter(budgetCategories: [.income])
                        fetchedTransactions = aggregation.transactions(context: context, transactionFilter: transactionFilter)
                        XCTAssertEqual(fetchedTransactions?.count, 1)

                        transactionFilter = TransactionFilter(baseType: .credit)
                        fetchedTransactions = aggregation.transactions(context: context, transactionFilter: transactionFilter)
                        XCTAssertEqual(fetchedTransactions?.count, 9)

                        transactionFilter = TransactionFilter(transactionCategoryIDs: [77, 102])
                        fetchedTransactions = aggregation.transactions(context: context, transactionFilter: transactionFilter)
                        XCTAssertEqual(fetchedTransactions?.count, 16)

                        transactionFilter = TransactionFilter(accountIDs: [2150])
                        fetchedTransactions = aggregation.transactions(context: context, transactionFilter: transactionFilter)
                        XCTAssertEqual(fetchedTransactions?.count, 26)

                        transactionFilter = TransactionFilter(merchantIDs: [1603])
                        fetchedTransactions = aggregation.transactions(context: context, transactionFilter: transactionFilter)
                        XCTAssertEqual(fetchedTransactions?.count, 8)
                    
                        transactionFilter = TransactionFilter(minimumAmount: "2.10", maximumAmount: "3.95")
                        fetchedTransactions = aggregation.transactions(context: context, transactionFilter: transactionFilter)
                        XCTAssertEqual(fetchedTransactions?.count, 1)
                    
                        transactionFilter = TransactionFilter(fromDate: "2020-01-03", toDate: "2020-01-15")
                        fetchedTransactions = aggregation.transactions(context: context, transactionFilter: transactionFilter)
                        XCTAssertEqual(fetchedTransactions?.count, 17)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 10.0)
        
    }
    
    func testCacheLogicForTransactionsSingleDay() {
        
        let expectation1 = expectation(description: "Database Request 1")
        
        database.setup { error in
            XCTAssertNil(error)

            let context = self.context

            context.performAndWait {
                let transaction1 = Transaction(context: context)
                transaction1.populateTestData()
                transaction1.transactionID = 1
                transaction1.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction2 = Transaction(context: context)
                transaction2.populateTestData()
                transaction2.transactionID = 2
                transaction2.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction3 = Transaction(context: context)
                transaction3.populateTestData()
                transaction3.transactionID = 3
                transaction3.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction4 = Transaction(context: context)
                transaction4.populateTestData()
                transaction4.transactionID = 4
                transaction4.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction5 = Transaction(context: context)
                transaction5.populateTestData()
                transaction5.transactionID = 5
                transaction5.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction6 = Transaction(context: context)
                transaction6.populateTestData()
                transaction6.transactionID = 6
                transaction6.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction7 = Transaction(context: context)
                transaction7.populateTestData()
                transaction7.transactionID = 7
                transaction7.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction8 = Transaction(context: context)
                transaction8.populateTestData()
                transaction8.transactionID = 8
                transaction8.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction9 = Transaction(context: context)
                transaction9.populateTestData()
                transaction9.transactionID = 9
                transaction9.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction10 = Transaction(context: context)
                transaction10.populateTestData()
                transaction10.transactionID = 10
                transaction10.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                
                let transaction11 = Transaction(context: context)
                transaction11.populateTestData()
                transaction11.transactionID = 11
                transaction11.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-12")!
                
                let transaction12 = Transaction(context: context)
                transaction12.populateTestData()
                transaction12.transactionID = 12
                transaction12.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-10")!

                try! context.save()
            }
            
            let filterPredicate1 = NSPredicate(format: "transactionDateString <= %@", argumentArray: ["2019-11-12"])
            let filterPredicate2 = NSPredicate(format: "transactionDateString == %@ || transactionID <= %@", argumentArray: ["2019-11-11", 5])
            let beforePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate1, filterPredicate2])
            
            let filterPredicate3 = NSPredicate(format: "transactionDateString >= %@", argumentArray: ["2019-11-10"])
            let filterPredicate4 = NSPredicate(format: "transactionDateString == %@ || transactionID >= %@", argumentArray: ["2019-11-11", 10])
            let afterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate3, filterPredicate4])
            
            let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [beforePredicate, afterPredicate])
            
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            fetchRequest.predicate = finalPredicate

            do {
                let fetchedTransactions = try context.fetch(fetchRequest)

                XCTAssertEqual(fetchedTransactions.count, 10)

            } catch {
                XCTFail(error.localizedDescription)
            }

            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
}




extension TransactionFilter {
    
    mutating func populateTestData() {
        accountIDs = [11,22,33]
        transactionIDs = [66,77,88,99]
        merchantIDs = [23,45,67,78]
        accountIncluded = true
        baseType = .credit
        budgetCategories = [.lifestyle, .savings]
        transactionCategoryIDs = [4546,5767,6883]
        fromDate = "2019-11-11"
        toDate = "2020-01-29"
        minimumAmount = "22.44"
        maximumAmount = "66.00"
        searchTerm = "Woolies"
        tags = ["Frollo&Volt", "Groceries Aldi"]
        transactionIncluded = false
    }
    
}
