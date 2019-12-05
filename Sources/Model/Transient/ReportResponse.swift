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

import Foundation

/// Represents an object that can be mapped from a GroupReport API response object
public protocol Reportable {
    
    /// The grouping type of the model
    static var grouping: ReportGrouping { get }
    
    /// Initializer from a group report object
    init(groupReport: APIReportsResponse.Report.GroupReport)
}

public class ReportResponse<T: Reportable> {
    public let groupReports: [T]
    public let isIncome: Bool
    public let date: String
    public let value: Double
    
    init(type: T.Type, report: APIReportsResponse.Report) {
        self.groupReports = report.groups.map { T(groupReport: $0) }
        self.isIncome = report.income
        self.date = report.date
        self.value = Double(report.value) ?? 0
    }
}

public typealias ReportsResponse<T: Reportable> = [ReportResponse<T>]

public class GroupReport {
    public var transactionIDs: [Int64]
    public var value: Double
    public var isIncome: Bool
    
    public init(transactionIDs: [Int64], value: Double, isIncome: Bool) {
        self.transactionIDs = transactionIDs
        self.value = value
        self.isIncome = isIncome
    }
    
    public init(groupReport: APIReportsResponse.Report.GroupReport) {
        self.transactionIDs = groupReport.transactionIDs
        self.value = Double(groupReport.value) ?? 0
        self.isIncome = groupReport.income
    }
}

public final class BudgetCategoryGroupReport: GroupReport {
    public var budgetCategory: BudgetCategory
    
    public override init(groupReport: APIReportsResponse.Report.GroupReport) {
        self.budgetCategory = BudgetCategory(id: groupReport.id) ?? .income
        super.init(groupReport: groupReport)
    }
}

extension BudgetCategoryGroupReport: Reportable {
    public static var grouping: ReportGrouping {
        return .budgetCategory
    }
}

public final class TransactionCategoryGroupReport: GroupReport {
    public var id: Int64
    
    public override init(groupReport: APIReportsResponse.Report.GroupReport) {
        self.id = groupReport.id
        super.init(groupReport: groupReport)
    }
}

extension TransactionCategoryGroupReport: Reportable {
    public static var grouping: ReportGrouping {
        return .transactionCategory
    }
}

public final class TagGroupReport: GroupReport {
    public var id: Int64
    
    public override init(groupReport: APIReportsResponse.Report.GroupReport) {
        self.id = groupReport.id
        super.init(groupReport: groupReport)
    }
}

extension TagGroupReport: Reportable {
    public static var grouping: ReportGrouping {
        return .tag
    }
}

public final class MerchantGroupReport: GroupReport {
    public var id: Int64
    
    public override init(groupReport: APIReportsResponse.Report.GroupReport) {
        self.id = groupReport.id
        super.init(groupReport: groupReport)
    }
}

extension MerchantGroupReport: Reportable {
    public static var grouping: ReportGrouping {
        return .merchant
    }
}
