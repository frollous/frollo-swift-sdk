//
//  Reports.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import Foundation

class Reports: ResponseHandler {
    
    private let aggregation: Aggregation
    private let database: Database
    private let network: Network
    
    private let reportsLock = NSLock()
    
    private var linkingMerchantIDs = Set<Int64>()
    private var linkingTransactionCategoryIDs = Set<Int64>()
    
    internal init(database: Database, network: Network, aggregation: Aggregation) {
        self.database = database
        self.network = network
        self.aggregation = aggregation
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
    
    private func linkReportTransactionHistoryToMerchants(managedObjectContext: NSManagedObjectContext) {
        reportsLock.lock()
        aggregation.merchantLock.lock()
        
        defer {
            reportsLock.unlock()
            aggregation.merchantLock.unlock()
        }
        
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " != nil && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.merchant.rawValue])
        linkObjectToParentObject(type: ReportTransactionHistory.self, parentType: Merchant.self, objectFilterPredicate: filterPredicate, managedObjectContext: managedObjectContext, linkedIDs: linkingTransactionCategoryIDs, linkedKey: \ReportTransactionHistory.linkedID, linkedKeyName: #keyPath(ReportTransactionHistory.linkedID))
        
        linkingTransactionCategoryIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkReportTransactionHistoryToTransactionCategories(managedObjectContext: NSManagedObjectContext) {
        reportsLock.lock()
        aggregation.transactionCategoryLock.lock()
        
        defer {
            reportsLock.unlock()
            aggregation.transactionCategoryLock.unlock()
        }
        
        let filterPredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " != nil && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.merchant.rawValue])
        linkObjectToParentObject(type: ReportTransactionHistory.self, parentType: Merchant.self, objectFilterPredicate: filterPredicate, managedObjectContext: managedObjectContext, linkedIDs: linkingTransactionCategoryIDs, linkedKey: \ReportTransactionHistory.linkedID, linkedKeyName: #keyPath(ReportTransactionHistory.linkedID))
        
        linkingTransactionCategoryIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleTransactionHistoryReportsResponse(_ reportsResponse: APITransactionHistoryReportsResponse, grouping: ReportGrouping, period: ReportTransactionHistory.Period, budgetCategory: BudgetCategory? = nil, managedObjectContext: NSManagedObjectContext) {
        reportsLock.lock()
        
        defer {
            reportsLock.unlock()
        }
        
        // Sort by date
        let sortedReportResponses = reportsResponse.data.sorted(by: { (responseA: APITransactionHistoryReportsResponse.Report, responseB: APITransactionHistoryReportsResponse.Report) -> Bool in
            return responseB.date > responseA.date
        })
        
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
            let datePredicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.dateString) + " IN %@", argumentArray: [reportDates])
            
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
                    
                    handleTransactionHistoryCategoryReportsResponse(reportResponse.categories, overallReport: report, managedObjectContext: managedObjectContext)
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
    
    private func handleTransactionHistoryCategoryReportsResponse(_ categoryReportsResponse: [APITransactionHistoryReportsResponse.Report.CategoryReport], overallReport: ReportTransactionHistory, managedObjectContext: NSManagedObjectContext) {
        // Sort by linked ID
        let sortedCategoryReportResponses = categoryReportsResponse.sorted(by: { (responseA: APITransactionHistoryReportsResponse.Report.CategoryReport, responseB: APITransactionHistoryReportsResponse.Report.CategoryReport) -> Bool in
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
                linkingMerchantIDs = linkingMerchantIDs.union(linkedIDs)
            case .transactionCategory:
                linkingTransactionCategoryIDs = linkingTransactionCategoryIDs.union(linkedIDs)
            default:
                break
        }
    }
    
}
