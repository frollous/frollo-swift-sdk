//
//  Reports.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import Foundation

/// Managed all aspects of reporting of aggregation data including spending and balances
public class Reports: ResponseHandler, CachedObjects {
    
    private let aggregation: Aggregation
    private let database: Database
    private let network: Network
    
    private let accountBalanceReportsLock = NSLock()
    private let currentReportsLock = NSLock()
    private let historyReportsLock = NSLock()
    
    private var linkingAccountIDs = Set<Int64>()
    private var linkingCurrentMerchantIDs = Set<Int64>()
    private var linkingCurrentTransactionCategoryIDs = Set<Int64>()
    private var linkingHistoryMerchantIDs = Set<Int64>()
    private var linkingHistoryTransactionCategoryIDs = Set<Int64>()
    private var refreshingMerchantIDs = Set<Int64>()
    
    internal init(database: Database, network: Network, aggregation: Aggregation) {
        self.database = database
        self.network = network
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
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to date ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func accountBalanceReports(context: NSManagedObjectContext, from fromDate: Date, to toDate: Date, period: ReportAccountBalance.Period, accountID: Int64? = nil, accountType: Account.AccountType? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true)], limit: Int? = nil) -> [ReportAccountBalance]? {
        let dateFormatter: DateFormatter
        switch period {
            case .day:
                dateFormatter = ReportTransactionHistory.dailyDateFormatter
            case .month:
                dateFormatter = ReportTransactionHistory.monthlyDateFormatter
            case .week:
                dateFormatter = ReportTransactionHistory.weeklyDateFormatter
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
        network.fetchAccountBalanceReports(period: period, from: fromDate, to: toDate, accountID: accountID, accountType: accountType) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let reportsResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAccountBalanceReportsResponse(reportsResponse, period: period, from: fromDate, to: toDate, accountID: accountID, accountType: accountType, managedObjectContext: managedObjectContext)
                    
                    self.linkAccountBalanceReportsToAccounts(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Transaction Current Reports
    
    /**
     Fetch current transaction reports from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - grouping: Grouping that reports should be broken down into
        - budgetCategory: Budget Category to filter reports by. Leave blank to return all reports of that grouping (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to day ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func currentTransactionReports(context: NSManagedObjectContext, grouping: ReportGrouping, budgetCategory: BudgetCategory? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)], limit: Int? = nil) -> [ReportTransactionCurrent]? {
        var predicates = [NSPredicate(format: #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [grouping.rawValue])]
        
        if let category = budgetCategory {
            predicates.append(NSPredicate(format: #keyPath(ReportTransactionCurrent.filterBudgetCategoryRawValue) + " == %@", argumentArray: [category.rawValue]))
        } else {
            predicates.append(NSPredicate(format: #keyPath(ReportTransactionCurrent.filterBudgetCategoryRawValue) + " == nil", argumentArray: nil))
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return currentTransactionReports(context: context, filteredBy: predicate, sortedBy: sortDescriptors, limit: limit)
    }
    
    /**
     Fetch current transaction reports from the cache by predicate (advanced)
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `ReportTransactionCurrent` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to day ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func currentTransactionReports(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)], limit: Int? = nil) -> [ReportTransactionCurrent]? {
        return cachedObjects(type: ReportTransactionCurrent.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh transaction current reports from the host
     
     - parameters:
         - grouping: Grouping that reports should be broken down into
         - budgetCategory: Budget category to filter reports by. Leave blank to return all reports (Optional)
         - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshTransactionCurrentReports(grouping: ReportGrouping, budgetCategory: BudgetCategory? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchTransactionCurrentReports(grouping: grouping, budgetCategory: budgetCategory) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let reportsResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionCurrentReportsResponse(reportsResponse, grouping: grouping, budgetCategory: budgetCategory, managedObjectContext: managedObjectContext)
                    
                    self.linkReportTransactionCurrentToMerchants(managedObjectContext: managedObjectContext)
                    self.linkReportTransactionCurrentToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Transaction History Reports
    
    /**
     Fetch historic transaction reports from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - fromDate: Start date to fetch reports from (inclusive)
        - toDate: End date to fetch reports up to (inclusive)
        - grouping: Grouping that reports should be broken down into
        - period: Period that reports should be broken down by
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to date ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func historyTransactionReports(context: NSManagedObjectContext, from fromDate: Date, to toDate: Date, grouping: ReportGrouping, period: ReportTransactionHistory.Period, budgetCategory: BudgetCategory? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)], limit: Int? = nil) -> [ReportTransactionHistory]? {
        let dateFormatter: DateFormatter
        switch period {
            case .day:
                dateFormatter = ReportTransactionHistory.dailyDateFormatter
            case .month:
                dateFormatter = ReportTransactionHistory.monthlyDateFormatter
            case .week:
                dateFormatter = ReportTransactionHistory.weeklyDateFormatter
        }
        
        let fromDateString = dateFormatter.string(from: fromDate)
        let toDateString = dateFormatter.string(from: toDate)
        let datePredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.dateString) + " >= %@ && " + #keyPath(ReportTransactionHistory.dateString) + " <= %@", argumentArray: [fromDateString, toDateString])
        
        let groupingPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: [grouping.rawValue])
        
        let periodPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [period.rawValue])
        
        var predicates = [datePredicate, groupingPredicate, periodPredicate]
        
        if let category = budgetCategory {
            predicates.append(NSPredicate(format: #keyPath(ReportTransactionHistory.filterBudgetCategoryRawValue) + " == %@", argumentArray: [category.rawValue]))
        } else {
            predicates.append(NSPredicate(format: #keyPath(ReportTransactionHistory.filterBudgetCategoryRawValue) + " == nil", argumentArray: nil))
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return historyTransactionReports(context: context, filteredBy: predicate, sortedBy: sortDescriptors, limit: limit)
    }
    
    /**
     Fetch historic transaction reports from the cache by predicate (advanced)
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `ReportTransactionCurrent` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to date ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func historyTransactionReports(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)], limit: Int? = nil) -> [ReportTransactionHistory]? {
        return cachedObjects(type: ReportTransactionHistory.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh transaction history reports from the host
     
     - parameters:
        - grouping: Grouping that reports should be broken down into
        - period: Period that reports should be broken down by
        - fromDate: Start date to fetch reports from (inclusive)
        - toDate: End date to fetch reports up to (inclusive)
        - budgetCategory: Budget category to filter reports by. Leave blank to return all reports (Optional)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshTransactionHistoryReports(grouping: ReportGrouping, period: ReportTransactionHistory.Period, from fromDate: Date, to toDate: Date, budgetCategory: BudgetCategory? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchTransactionHistoryReports(grouping: grouping, period: period, fromDate: fromDate, toDate: toDate, budgetCategory: budgetCategory) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let reportsResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionHistoryReportsResponse(reportsResponse, grouping: grouping, period: period, from: fromDate, to: toDate, budgetCategory: budgetCategory, managedObjectContext: managedObjectContext)
                    
                    self.linkReportTransactionHistoryToMerchants(managedObjectContext: managedObjectContext)
                    self.linkReportTransactionHistoryToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
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
    
    private func linkReportTransactionCurrentToMerchants(managedObjectContext: NSManagedObjectContext) {
        currentReportsLock.lock()
        aggregation.merchantLock.lock()
        
        defer {
            currentReportsLock.unlock()
            aggregation.merchantLock.unlock()
        }
        
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.linkedID) + " != -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.merchant.rawValue])
        let missingMerchantIDs = linkObjectToParentObject(type: ReportTransactionCurrent.self, parentType: Merchant.self, objectFilterPredicate: filterPredicate, managedObjectContext: managedObjectContext, linkedIDs: linkingCurrentMerchantIDs, linkedKey: \ReportTransactionCurrent.linkedID, linkedKeyName: #keyPath(ReportTransactionCurrent.linkedID))
        
        linkingCurrentMerchantIDs = missingMerchantIDs
        
        let merchantIDs = missingMerchantIDs.subtracting(refreshingMerchantIDs)
        
        if !merchantIDs.isEmpty {
            refreshingMerchantIDs = refreshingMerchantIDs.union(merchantIDs)
            aggregation.refreshMerchants(merchantIDs: Array(merchantIDs))
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkReportTransactionCurrentToTransactionCategories(managedObjectContext: NSManagedObjectContext) {
        currentReportsLock.lock()
        aggregation.transactionCategoryLock.lock()
        
        defer {
            currentReportsLock.unlock()
            aggregation.transactionCategoryLock.unlock()
        }
        
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.linkedID) + " != -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.transactionCategory.rawValue])
        linkObjectToParentObject(type: ReportTransactionCurrent.self, parentType: TransactionCategory.self, objectFilterPredicate: filterPredicate, managedObjectContext: managedObjectContext, linkedIDs: linkingCurrentTransactionCategoryIDs, linkedKey: \ReportTransactionCurrent.linkedID, linkedKeyName: #keyPath(ReportTransactionCurrent.linkedID))
        
        linkingCurrentTransactionCategoryIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkReportTransactionHistoryToMerchants(managedObjectContext: NSManagedObjectContext) {
        historyReportsLock.lock()
        aggregation.merchantLock.lock()
        
        defer {
            historyReportsLock.unlock()
            aggregation.merchantLock.unlock()
        }
        
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " != nil && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.merchant.rawValue])
        let missingMerchantIDs = linkObjectToParentObject(type: ReportTransactionHistory.self, parentType: Merchant.self, objectFilterPredicate: filterPredicate, managedObjectContext: managedObjectContext, linkedIDs: linkingHistoryMerchantIDs, linkedKey: \ReportTransactionHistory.linkedID, linkedKeyName: #keyPath(ReportTransactionHistory.linkedID))
        
        linkingHistoryMerchantIDs = missingMerchantIDs
        
        let merchantIDs = missingMerchantIDs.subtracting(refreshingMerchantIDs)
        
        if !merchantIDs.isEmpty {
            refreshingMerchantIDs = refreshingMerchantIDs.union(merchantIDs)
            aggregation.refreshMerchants(merchantIDs: Array(merchantIDs))
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkReportTransactionHistoryToTransactionCategories(managedObjectContext: NSManagedObjectContext) {
        historyReportsLock.lock()
        aggregation.transactionCategoryLock.lock()
        
        defer {
            historyReportsLock.unlock()
            aggregation.transactionCategoryLock.unlock()
        }
        
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " != nil && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.transactionCategory.rawValue])
        linkObjectToParentObject(type: ReportTransactionHistory.self, parentType: TransactionCategory.self, objectFilterPredicate: filterPredicate, managedObjectContext: managedObjectContext, linkedIDs: linkingHistoryTransactionCategoryIDs, linkedKey: \ReportTransactionHistory.linkedID, linkedKeyName: #keyPath(ReportTransactionHistory.linkedID))
        
        linkingHistoryTransactionCategoryIDs = Set()
        
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
            return responseB.date > responseA.date
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
            return responseB.id > responseA.id
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
                    
                    if index < existingReports.count && existingReports[index].accountID == reportResponse.id {
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
    
    private func handleTransactionCurrentReportsResponse(_ reportsResponse: APITransactionCurrentReportResponse, grouping: ReportGrouping, budgetCategory: BudgetCategory? = nil, managedObjectContext: NSManagedObjectContext) {
        currentReportsLock.lock()
        
        defer {
            currentReportsLock.unlock()
        }
        
        var linkedIDs = Set<Int64>()
        
        // Handle overall spends
        handleTransactionCurrentDayReportsResponse(reportsResponse.days, grouping: grouping, budgetCategory: budgetCategory, linkedID: -1, name: nil, managedObjectContext: managedObjectContext)
        
        // Handle group breakdowns
        for groupResponse in reportsResponse.groups {
            linkedIDs.insert(groupResponse.id)
            
            handleTransactionCurrentDayReportsResponse(groupResponse.days, grouping: grouping, budgetCategory: budgetCategory, linkedID: groupResponse.id, name: groupResponse.name, managedObjectContext: managedObjectContext)
        }
        
        switch grouping {
            case .merchant:
                linkingCurrentMerchantIDs = linkingCurrentMerchantIDs.union(linkedIDs)
            case .transactionCategory:
                linkingCurrentTransactionCategoryIDs = linkingCurrentTransactionCategoryIDs.union(linkedIDs)
            default:
                break
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleTransactionCurrentDayReportsResponse(_ reportsResponse: [APITransactionCurrentReportResponse.Report], grouping: ReportGrouping, budgetCategory: BudgetCategory? = nil, linkedID: Int64, name: String?, managedObjectContext: NSManagedObjectContext) {
        // Sort by day
        let sortedReportResponses = reportsResponse.sorted { (responseA: APITransactionCurrentReportResponse.Report, responseB: APITransactionCurrentReportResponse.Report) -> Bool in
            return responseB.day > responseA.day
        }
        
        let reportDays = sortedReportResponses.map { return $0.day }
        
        managedObjectContext.performAndWait {
            // Fetch existing reports for updating
            let fetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
            
            // Fetch by linkedID: -1 is overall
            let linkedIDPredicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.linkedID) + " == %ld", argumentArray: [linkedID])
            // Filter by grouping method
            let groupingPredicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [grouping.rawValue])
            
            var filterPredicates = [linkedIDPredicate, groupingPredicate]
            
            // Filter by budget category if applicable
            if let category = budgetCategory {
                filterPredicates.append(NSPredicate(format: #keyPath(ReportTransactionCurrent.filterBudgetCategoryRawValue) + " == %@", argumentArray: [category.rawValue]))
            } else {
                filterPredicates.append(NSPredicate(format: #keyPath(ReportTransactionCurrent.filterBudgetCategoryRawValue) + " == nil", argumentArray: nil))
            }
            
            // Specify dates
            let datePredicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " IN %@", argumentArray: [reportDays])
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterPredicates + [datePredicate])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
            
            do {
                let existingReports = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for reportResponse in sortedReportResponses {
                    var report: ReportTransactionCurrent
                    
                    if index < existingReports.count && existingReports[index].day == reportResponse.day {
                        report = existingReports[index]
                        index += 1
                    } else {
                        report = ReportTransactionCurrent(context: managedObjectContext)
                        report.grouping = grouping
                        report.filterBudgetCategory = budgetCategory
                    }
                    
                    report.day = reportResponse.day
                    report.linkedID = linkedID
                    report.name = name
                    
                    if report.grouping == .budgetCategory, let budgetName = name {
                        report.budgetCategory = BudgetCategory(rawValue: budgetName)
                    } else {
                        report.budgetCategory = nil
                    }
                    
                    if let value = reportResponse.spendValue {
                        report.amount = NSDecimalNumber(string: value)
                    } else {
                        report.amount = nil
                    }
                    if let value = reportResponse.averageValue {
                        report.average = NSDecimalNumber(string:value)
                    } else {
                        report.average = nil
                    }
                    if let value = reportResponse.budgetValue {
                        report.budget = NSDecimalNumber(string: value)
                    } else {
                        report.budget = nil
                    }
                    if let value = reportResponse.previousPeriodValue {
                        report.previous = NSDecimalNumber(string: value)
                    } else {
                        report.previous = nil
                    }
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                
                var deletePredicates = filterPredicates
                deletePredicates.append(NSCompoundPredicate(notPredicateWithSubpredicate: datePredicate))
                
                deleteRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: deletePredicates)
                
                do {
                    let deleteObjects = try managedObjectContext.fetch(deleteRequest)
                    
                    for deleteObject in deleteObjects {
                        managedObjectContext.delete(deleteObject)
                    }
                } catch let fetchError {
                    Log.error(fetchError.localizedDescription)
                }
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleTransactionHistoryReportsResponse(_ reportsResponse: APITransactionHistoryReportsResponse, grouping: ReportGrouping, period: ReportTransactionHistory.Period, from fromDate: Date, to toDate: Date, budgetCategory: BudgetCategory? = nil, managedObjectContext: NSManagedObjectContext) {
        historyReportsLock.lock()
        
        defer {
            historyReportsLock.unlock()
        }
        
        // Sort by date
        let sortedReportResponses = reportsResponse.data.sorted { (responseA: APITransactionHistoryReportsResponse.Report, responseB: APITransactionHistoryReportsResponse.Report) -> Bool in
            return responseB.date > responseA.date
        }
        
        let reportDates = sortedReportResponses.map { $0.date }
        
        managedObjectContext.performAndWait {
            // Fetch existing reports for updating
            let fetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
            
            // No parent reports - fetch top level only
            let overallPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil", argumentArray: nil)
            
            // Filter by grouping method
            let groupingPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: [grouping.rawValue])
            
            // Filter by period
            let periodPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [period.rawValue])
            
            // Date range
            let dateFormatter: DateFormatter
            switch period {
                case .day:
                    dateFormatter = ReportTransactionHistory.dailyDateFormatter
                case .month:
                    dateFormatter = ReportTransactionHistory.monthlyDateFormatter
                case .week:
                    dateFormatter = ReportTransactionHistory.weeklyDateFormatter
            }
            
            let fromDateString = dateFormatter.string(from: fromDate)
            let toDateString = dateFormatter.string(from: toDate)
            let dateRangePredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.dateString) + " >= %@ && " + #keyPath(ReportTransactionHistory.dateString) + " <= %@", argumentArray: [fromDateString, toDateString])
            
            var filterPredicates = [overallPredicate, groupingPredicate, periodPredicate, dateRangePredicate]
            
            // Filter by budget category if applicable
            if let category = budgetCategory {
                filterPredicates.append(NSPredicate(format: #keyPath(ReportTransactionHistory.filterBudgetCategoryRawValue) + " == %@", argumentArray: [category.rawValue]))
            } else {
                filterPredicates.append(NSPredicate(format: #keyPath(ReportTransactionHistory.filterBudgetCategoryRawValue) + " == nil", argumentArray: nil))
            }
            
            // Specify dates
            let datePredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.dateString) + " IN %@", argumentArray: [reportDates])
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterPredicates + [datePredicate])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
            
            do {
                let existingReports = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for reportResponse in sortedReportResponses {
                    var report: ReportTransactionHistory
                    
                    if index < existingReports.count && existingReports[index].dateString == reportResponse.date {
                        report = existingReports[index]
                        index += 1
                    } else {
                        report = ReportTransactionHistory(context: managedObjectContext)
                        report.grouping = grouping
                        report.period = period
                        report.filterBudgetCategory = budgetCategory
                    }
                    
                    report.dateString = reportResponse.date
                    report.value = NSDecimalNumber(string: reportResponse.value)
                    
                    if let value = reportResponse.budget {
                        report.budget = NSDecimalNumber(string: value)
                    } else {
                        report.budget = nil
                    }
                    
                    handleTransactionHistoryGroupReportsResponse(reportResponse.groups, overallReport: report, managedObjectContext: managedObjectContext)
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                
                var deletePredicates = filterPredicates
                deletePredicates.append(NSCompoundPredicate(notPredicateWithSubpredicate: datePredicate))
                
                deleteRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: deletePredicates)
                
                do {
                    let deleteObjects = try managedObjectContext.fetch(deleteRequest)
                    
                    for deleteObject in deleteObjects {
                        managedObjectContext.delete(deleteObject)
                    }
                } catch let fetchError {
                    Log.error(fetchError.localizedDescription)
                }
            } catch {
                Log.error(error.localizedDescription)
            }
            
            managedObjectContext.performAndWait {
                do {
                    try managedObjectContext.save()
                } catch {
                    Log.error(error.localizedDescription)
                }
            }
        }
    }
    
    private func handleTransactionHistoryGroupReportsResponse(_ categoryReportsResponse: [APITransactionHistoryReportsResponse.Report.GroupReport], overallReport: ReportTransactionHistory, managedObjectContext: NSManagedObjectContext) {
        // Sort by linked ID
        let sortedCategoryReportResponses = categoryReportsResponse.sorted(by: { (responseA: APITransactionHistoryReportsResponse.Report.GroupReport, responseB: APITransactionHistoryReportsResponse.Report.GroupReport) -> Bool in
            return responseB.id > responseA.id
        })
        
        var linkedIDs = Set<Int64>()
        
        let categoryReportIDs = sortedCategoryReportResponses.map { $0.id }
        
        // Split existing child reports into matching and orphaned
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.linkedID) + " IN %@", argumentArray: [categoryReportIDs])
        if let filteredGroupReports = overallReport.reports?.filtered(using: filterPredicate) as? Set<ReportTransactionHistory>,
            let orphanedGroupReports = overallReport.reports?.filtered(using: NSCompoundPredicate(notPredicateWithSubpredicate: filterPredicate)) as? Set<ReportTransactionHistory> {
            let existingGroupReports = filteredGroupReports.sorted(by: { (reportA: ReportTransactionHistory, reportB: ReportTransactionHistory) -> Bool in
                return reportB.linkedID > reportA.linkedID
            })
            
            var index = 0
            
            for groupReportResponse in sortedCategoryReportResponses {
                var groupReport: ReportTransactionHistory
                
                if index < existingGroupReports.count && existingGroupReports[index].linkedID == groupReportResponse.id {
                    groupReport = existingGroupReports[index]
                    index += 1
                } else {
                    groupReport = ReportTransactionHistory(context: managedObjectContext)
                    groupReport.overall = overallReport
                    groupReport.dateString = overallReport.dateString
                    groupReport.period = overallReport.period
                    groupReport.grouping = overallReport.grouping
                    groupReport.filterBudgetCategory = overallReport.filterBudgetCategory
                }
                
                groupReport.linkedID = groupReportResponse.id
                groupReport.value = NSDecimalNumber(string: groupReportResponse.value)
                groupReport.name = groupReportResponse.name
                
                if groupReport.grouping == .budgetCategory {
                    groupReport.budgetCategory = BudgetCategory(rawValue: groupReportResponse.name)
                } else {
                    groupReport.budgetCategory = nil
                }
                
                if let value = groupReportResponse.budget {
                    groupReport.budget = NSDecimalNumber(string: value)
                } else {
                    groupReport.budget = nil
                }
                
                linkedIDs.insert(groupReport.linkedID)
            }
            
            // Delete any leftovers
            for orphanedGroupReport in orphanedGroupReports {
                managedObjectContext.delete(orphanedGroupReport)
            }
        }
        
        switch overallReport.grouping {
            case .merchant:
                linkingHistoryMerchantIDs = linkingHistoryMerchantIDs.union(linkedIDs)
            case .transactionCategory:
                linkingHistoryTransactionCategoryIDs = linkingHistoryTransactionCategoryIDs.union(linkedIDs)
            default:
                break
        }
    }
    
}
