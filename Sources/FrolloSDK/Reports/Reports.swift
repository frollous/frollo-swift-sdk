//
// Copyright © 2019 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import CoreData
import Foundation

/// Managed all aspects of reporting of aggregation data including spending and balances
public class Reports: ResponseHandler, CachedObjects {
    
    private let aggregation: Aggregation
    private let database: Database
    private let service: APIService
    
    private let accountBalanceReportsLock = NSLock()
    private let currentReportsLock = NSLock()
    private let historyReportsLock = NSLock()
    
    private var linkingAccountIDs = Set<Int64>()
    private var linkingCurrentMerchantIDs = Set<Int64>()
    private var linkingCurrentTransactionCategoryIDs = Set<Int64>()
    private var linkingHistoryMerchantIDs = Set<Int64>()
    private var linkingHistoryTransactionCategoryIDs = Set<Int64>()
    private var refreshingMerchantIDs = Set<Int64>()
    
    internal init(database: Database, service: APIService, aggregation: Aggregation) {
        self.database = database
        self.service = service
        self.aggregation = aggregation
    }
    
    // MARK: - Account Balance Reports
    
    /**
     Fetch account balance reports from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - fromDate: Start date to fetch reports from (inclusive)
        - toDate: End date to fetch reports up to (inclusive)
        - period: Period that reports should be broken down by
        - accountID: Fetch reports for a specific account ID (optional)
        - accountType: Fetch reports for a specific account type (optional)
        - filteredBy: Predicate of properties to match for fetching. See `ReportAccountBalance` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to date ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func accountBalanceReports(context: NSManagedObjectContext,
                                      from fromDate: Date,
                                      to toDate: Date,
                                      period: ReportAccountBalance.Period,
                                      accountID: Int64? = nil,
                                      accountType: Account.AccountType? = nil,
                                      filteredBy predicate: NSPredicate? = nil,
                                      sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true)],
                                      limit: Int? = nil) -> [ReportAccountBalance]? {
        let dateFormatter: DateFormatter
        switch period {
            case .day:
                dateFormatter = Reports.dailyDateFormatter
            case .month:
                dateFormatter = Reports.monthlyDateFormatter
            case .week:
                dateFormatter = Reports.weeklyDateFormatter
        }
        
        let fromDateString = dateFormatter.string(from: fromDate)
        let toDateString = dateFormatter.string(from: toDate)
        
        let datePredicate = NSPredicate(format: #keyPath(ReportAccountBalance.dateString) + " >= %@ && " + #keyPath(ReportAccountBalance.dateString) + " <= %@", argumentArray: [fromDateString, toDateString])
        
        let periodPredicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@", argumentArray: [period.rawValue])
        
        var predicates = [datePredicate, periodPredicate]
        
        if let account = accountID {
            predicates.append(NSPredicate(format: #keyPath(ReportAccountBalance.accountID) + " == %ld", argumentArray: [account]))
        }
        if let container = accountType {
            predicates.append(NSPredicate(format: #keyPath(ReportAccountBalance.account.accountTypeRawValue) + " == %@", argumentArray: [container.rawValue]))
        }
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return accountBalanceReports(context: context, filteredBy: predicate, sortedBy: sortDescriptors, limit: limit)
    }
    
    /**
     Fetch account balance reports from the cache by predicate (advanced)
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `ReportAccountBalance` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to date ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func accountBalanceReports(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true)], limit: Int? = nil) -> [ReportAccountBalance]? {
        return cachedObjects(type: ReportAccountBalance.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh account balance reports from the host
     
     - parameters:
         - period: Period that reports should be broken down by
         - fromDate: Start date to fetch reports from (inclusive)
         - toDate: End date to fetch reports up to (inclusive)
         - accountID: ID of the account to fetch balance reports from (Optional)
         - accountType: Account container types to fetch balance reports from (Optional)
         - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshAccountBalanceReports(period: ReportAccountBalance.Period, from fromDate: Date, to toDate: Date, accountID: Int64? = nil, accountType: Account.AccountType? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchAccountBalanceReports(period: period, from: fromDate, to: toDate, accountID: accountID, accountType: accountType) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAccountBalanceReportsResponse(response, period: period, from: fromDate, to: toDate, accountID: accountID, accountType: accountType, managedObjectContext: managedObjectContext)
                    
                    self.linkAccountBalanceReportsToAccounts(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Transaction History Reports
    
    /**
     Fetch transaction history reports from the host
     
     - parameters:
        - filtering: The entity to filter on
        - grouping: Grouping that reports should be broken down into
        - period: Period that reports should be broken down by
        - fromDate: Start date to fetch reports from (inclusive)
        - toDate: End date to fetch reports up to (inclusive)
        - completion: Completion handler with either the data from the host or an error
     */
    public func fetchTransactionReports<T: Reportable>(filtering: TransactionReportFilter, grouping: T.Type, period: Reports.Period, from fromDate: Date, to toDate: Date, completion: @escaping (Result<[ReportResponse<T>], Error>) -> Void) {
        service.fetchTransactionHistoryReports(filtering: filtering, grouping: T.grouping, period: period, fromDate: fromDate, toDate: toDate) { result in
            switch result {
                case .success(let response):
                    let reports = response.data.map { ReportResponse(type: T.self, report: $0) }
                    completion(.success(reports))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    /**
     Fetch transaction history reports from the host grouped by categories
     
     - parameters:
        - id: The id of the category to filter on, or nil if no filtering is required
        - period: Period that reports should be broken down by
        - fromDate: Start date to fetch reports from (inclusive)
        - toDate: End date to fetch reports up to (inclusive)
        - completion: Completion handler with either the data from the host or an error
     */
    public func fetchTransactionCategoryReports(_ id: Int64? = nil, period: Reports.Period, from fromDate: Date, to toDate: Date, completion: @escaping (Result<[ReportResponse<TransactionCategoryGroupReport>], Error>) -> Void) {
        fetchTransactionReports(filtering: .category(id: id), grouping: TransactionCategoryGroupReport.self, period: period, from: fromDate, to: toDate, completion: completion)
    }
    
    /**
     Fetch transaction history reports from the host grouped by merchants
     
     - parameters:
        - id: The id of the merchant to filter on, or nil if no filtering is required
        - period: Period that reports should be broken down by
        - fromDate: Start date to fetch reports from (inclusive)
        - toDate: End date to fetch reports up to (inclusive)
        - completion: Completion handler with either the data from the host or an error
     */
    public func fetchTransactionMerchantReports(_ id: Int64? = nil, period: Reports.Period, from fromDate: Date, to toDate: Date, completion: @escaping (Result<[ReportResponse<MerchantGroupReport>], Error>) -> Void) {
        fetchTransactionReports(filtering: .merchant(id: id), grouping: MerchantGroupReport.self, period: period, from: fromDate, to: toDate, completion: completion)
    }
    
    /**
     Fetch transaction history reports from the host grouped by budget categories
     
     - parameters:
        - id: The id of the budget category to filter on, or nil if no filtering is required
        - period: Period that reports should be broken down by
        - fromDate: Start date to fetch reports from (inclusive)
        - toDate: End date to fetch reports up to (inclusive)
        - completion: Completion handler with either the data from the host or an error
     */
    public func fetchTransactionBudgetCategoryReports(_ budgetCategory: BudgetCategory? = nil, period: Reports.Period, from fromDate: Date, to toDate: Date, completion: @escaping (Result<[ReportResponse<BudgetCategoryGroupReport>], Error>) -> Void) {
        fetchTransactionReports(filtering: .budgetCategory(id: budgetCategory?.id), grouping: BudgetCategoryGroupReport.self, period: period, from: fromDate, to: toDate, completion: completion)
    }
    
    /**
     Fetch transaction history reports from the host grouped by tags
     
     - parameters:
        - id: The id of the tag to filter on, or nil if no filtering is required
        - period: Period that reports should be broken down by
        - fromDate: Start date to fetch reports from (inclusive)
        - toDate: End date to fetch reports up to (inclusive)
        - completion: Completion handler with either the data from the host or an error
     */
    public func fetchTransactionTagReports(_ name: String? = nil, period: Reports.Period, from fromDate: Date, to toDate: Date, completion: @escaping (Result<[ReportResponse<TagGroupReport>], Error>) -> Void) {
        fetchTransactionReports(filtering: .tag(name: name), grouping: TagGroupReport.self, period: period, from: fromDate, to: toDate, completion: completion)
    }
    
    // MARK: - Linking Objects
    
    private func linkAccountBalanceReportsToAccounts(managedObjectContext: NSManagedObjectContext) {
        accountBalanceReportsLock.lock()
        aggregation.accountLock.lock()
        
        defer {
            accountBalanceReportsLock.unlock()
            aggregation.accountLock.unlock()
        }
        
        linkObjectToParentObject(type: ReportAccountBalance.self, parentType: Account.self, managedObjectContext: managedObjectContext, linkedIDs: linkingAccountIDs, linkedKey: \ReportAccountBalance.accountID, linkedKeyName: #keyPath(ReportAccountBalance.accountID))
        
        linkingAccountIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleAccountBalanceReportsResponse(_ reportsResponse: APIAccountBalanceReportResponse, period: ReportAccountBalance.Period, from fromDate: Date, to toDate: Date, accountID: Int64? = nil, accountType: Account.AccountType? = nil, managedObjectContext: NSManagedObjectContext) {
        accountBalanceReportsLock.lock()
        
        defer {
            accountBalanceReportsLock.unlock()
        }
        
        // Sort by date
        let sortedReportResponses = reportsResponse.data.sorted { (responseA: APIAccountBalanceReportResponse.Report, responseB: APIAccountBalanceReportResponse.Report) -> Bool in
            responseB.date > responseA.date
        }
        
        for reportResponse in sortedReportResponses {
            handleAccountBalanceReportsForDate(reportResponse.date, managedObjectContext: managedObjectContext, reportsResponses: reportResponse.accounts, period: period, accountID: accountID, accountType: accountType)
        }
        
        managedObjectContext.perform {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleAccountBalanceReportsForDate(_ dateString: String, managedObjectContext: NSManagedObjectContext, reportsResponses: [APIAccountBalanceReportResponse.Report.BalanceReport], period: ReportAccountBalance.Period, accountID: Int64?, accountType: Account.AccountType?) {
        // Sort by account ID
        let sortedReportResponses = reportsResponses.sorted { (responseA: APIAccountBalanceReportResponse.Report.BalanceReport, responseB: APIAccountBalanceReportResponse.Report.BalanceReport) -> Bool in
            responseB.id > responseA.id
        }
        
        let reportAccountIDs = sortedReportResponses.map { $0.id }
        linkingAccountIDs = linkingAccountIDs.union(reportAccountIDs)
        
        managedObjectContext.performAndWait {
            // Fetch existing reports for updating
            let fetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
            
            // Filter by period
            let periodPredicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@", argumentArray: [period.rawValue])
            
            // Specify date
            let datePredicate = NSPredicate(format: #keyPath(ReportAccountBalance.dateString) + " == %@", argumentArray: [dateString])
            
            var filterPredicates = [periodPredicate, datePredicate]
            
            // Filter by account type if applicable
            if let container = accountType {
                filterPredicates.append(NSPredicate(format: #keyPath(ReportAccountBalance.account.accountTypeRawValue) + " == %@", argumentArray: [container.rawValue]))
            }
            
            // Filter by account IDs
            let accountsPredicate: NSPredicate
            if let account = accountID {
                accountsPredicate = NSPredicate(format: #keyPath(ReportAccountBalance.accountID) + " == %ld", argumentArray: [account])
            } else {
                accountsPredicate = NSPredicate(format: #keyPath(ReportAccountBalance.accountID) + " IN %@", argumentArray: [reportAccountIDs])
            }
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterPredicates + [accountsPredicate])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
            
            do {
                let existingReports = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for reportResponse in sortedReportResponses {
                    var report: ReportAccountBalance
                    
                    if index < existingReports.count, existingReports[index].accountID == reportResponse.id {
                        report = existingReports[index]
                        index += 1
                    } else {
                        report = ReportAccountBalance(context: managedObjectContext)
                        report.dateString = dateString
                        report.period = period
                    }
                    
                    report.accountID = reportResponse.id
                    report.currency = reportResponse.currency
                    report.value = NSDecimalNumber(string: reportResponse.value)
                }
                
                // Fetch and delete any leftovers if fetching multiple accounts
                if accountID == nil {
                    let deleteRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
                    
                    var deletePredicates = filterPredicates
                    deletePredicates.append(NSCompoundPredicate(notPredicateWithSubpredicate: accountsPredicate))
                    
                    deleteRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: deletePredicates)
                    
                    do {
                        let deleteObjects = try managedObjectContext.fetch(deleteRequest)
                        
                        for deleteObject in deleteObjects {
                            managedObjectContext.delete(deleteObject)
                        }
                    } catch let fetchError {
                        Log.error(fetchError.localizedDescription)
                    }
                }
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
}
