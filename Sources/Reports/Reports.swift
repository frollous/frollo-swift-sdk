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
class Reports: ResponseHandler {
    
    private let aggregation: Aggregation
    private let database: Database
    private let network: Network
    
    private let currentReportsLock = NSLock()
    private let historyReportsLock = NSLock()
    
    private var linkingCurrentMerchantIDs = Set<Int64>()
    private var linkingCurrentTransactionCategoryIDs = Set<Int64>()
    private var linkingHistoryMerchantIDs = Set<Int64>()
    private var linkingHistoryTransactionCategoryIDs = Set<Int64>()
    
    internal init(database: Database, network: Network, aggregation: Aggregation) {
        self.database = database
        self.network = network
        self.aggregation = aggregation
    }
    
    /**
     Refresh transaction current reports from the host
     
     - parameters:
         - grouping: Grouping that reports should be broken down into
         - budgetCategory: Budget category to filter reports by. Leave blank to return all reports (Optional)
         - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshTransactionHistoryReports(grouping: ReportGrouping, budgetCategory: BudgetCategory? = nil, completion: FrolloSDKCompletionHandler? = nil) {
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
                    
                    self.handleTransactionHistoryReportsResponse(reportsResponse, grouping: grouping, period: period, budgetCategory: budgetCategory, managedObjectContext: managedObjectContext)
                    
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
    
    private func linkReportTransactionCurrentToMerchants(managedObjectContext: NSManagedObjectContext) {
        currentReportsLock.lock()
        aggregation.merchantLock.lock()
        
        defer {
            currentReportsLock.unlock()
            aggregation.merchantLock.unlock()
        }
        
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.linkedID) + " != -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.merchant.rawValue])
        linkObjectToParentObject(type: ReportTransactionCurrent.self, parentType: Merchant.self, objectFilterPredicate: filterPredicate, managedObjectContext: managedObjectContext, linkedIDs: linkingCurrentTransactionCategoryIDs, linkedKey: \ReportTransactionCurrent.linkedID, linkedKeyName: #keyPath(ReportTransactionCurrent.linkedID))
        
        linkingCurrentTransactionCategoryIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkReportTransactionCurrentToTransactionCategories(managedObjectContext: NSManagedObjectContext) {
        historyReportsLock.lock()
        aggregation.transactionCategoryLock.lock()
        
        defer {
            historyReportsLock.unlock()
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
        linkObjectToParentObject(type: ReportTransactionHistory.self, parentType: Merchant.self, objectFilterPredicate: filterPredicate, managedObjectContext: managedObjectContext, linkedIDs: linkingHistoryTransactionCategoryIDs, linkedKey: \ReportTransactionHistory.linkedID, linkedKeyName: #keyPath(ReportTransactionHistory.linkedID))
        
        linkingHistoryTransactionCategoryIDs = Set()
        
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
                linkingCurrentMerchantIDs = linkingCurrentTransactionCategoryIDs.union(linkedIDs)
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
        currentReportsLock.lock()
        
        defer {
            currentReportsLock.unlock()
        }
        
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
                filterPredicates.append(NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == %@", argumentArray: [category.rawValue]))
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
                        report.budgetCategory = budgetCategory
                    }
                    
                    report.day = reportResponse.day
                    report.linkedID = linkedID
                    report.name = name
                    report.amount = NSDecimalNumber(string: reportResponse.spendValue)
                    report.average = NSDecimalNumber(string: reportResponse.averageValue)
                    report.budget = NSDecimalNumber(string: reportResponse.budgetValue)
                    report.previous = NSDecimalNumber(string: reportResponse.previousPeriodValue)
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
        }
    }
    
    private func handleTransactionHistoryReportsResponse(_ reportsResponse: APITransactionHistoryReportsResponse, grouping: ReportGrouping, period: ReportTransactionHistory.Period, budgetCategory: BudgetCategory? = nil, managedObjectContext: NSManagedObjectContext) {
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
            
            var filterPredicates = [overallPredicate, groupingPredicate, periodPredicate]
            
            // Filter by budget category if applicable
            if let category = budgetCategory {
                filterPredicates.append(NSPredicate(format: #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == %@", argumentArray: [category.rawValue]))
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
                        report.budgetCategory = budgetCategory
                    }
                    
                    report.dateString = reportResponse.date
                    report.value = NSDecimalNumber(string: reportResponse.value)
                    
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
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.linkedID) + " IN %@", argumentArray: categoryReportIDs)
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
                    groupReport.period = overallReport.period
                    groupReport.grouping = overallReport.grouping
                    groupReport.budgetCategory = overallReport.budgetCategory
                }
                
                groupReport.linkedID = groupReportResponse.id
                groupReport.budget = NSDecimalNumber(string: groupReportResponse.budget)
                groupReport.value = NSDecimalNumber(string: groupReportResponse.value)
                groupReport.name = groupReportResponse.name
                
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
