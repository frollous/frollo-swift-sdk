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
    
    /// The value of the report item
    var value: Decimal { get }
    
    /// The name of the report item
    var name: String { get }
    
    /// Initializer from a group report object
    init(groupReport: APIGroupReport)
    
}

/// Response from the API with details on the reports and reports themselves
public class ReportResponse<T: Reportable> {
    
    /// Reports in their grouping
    public let groupReports: [T]
    
    /// Indicates if the report represents income or expense. i.e. if false this means this value is a summation of negative values presented as a positive figure
    public let isIncome: Bool
    
    /// Date of the start of the report
    public let date: String
    
    /// Value of the report
    public let value: Decimal
    
    internal init(type: T.Type, report: APIReportsResponse.Report) {
        self.groupReports = report.groups.map { T(groupReport: $0) }
        self.isIncome = report.income
        self.date = report.date
        self.value = report.value
    }
    
}

/// Report grouped by the requested grouping
public class GroupReport {
    
    /// Transaction IDs included in the report
    public var transactionIDs: [Int64]
    
    /// Name of the report
    public var name: String
    
    /// Value of the group report
    public var value: Decimal
    
    /// Indicates if the report represents income or expense. i.e. if false this means this value is a summation of negative values presented as a positive figure
    public var isIncome: Bool
    
    internal init(transactionIDs: [Int64], name: String, value: Decimal, isIncome: Bool) {
        self.transactionIDs = transactionIDs
        self.name = name
        self.value = value
        self.isIncome = isIncome
    }
    
    internal init(groupReport: APIGroupReport) {
        self.transactionIDs = groupReport.transactionIDs
        self.name = groupReport.name
        self.value = groupReport.value
        self.isIncome = groupReport.income
    }
}

/// Budget Category Group Report
public final class BudgetCategoryGroupReport: GroupReport {
    
    /// The budget category of the report
    public var budgetCategory: BudgetCategory
    
    /// Initializer from a group report object
    public override init(groupReport: APIGroupReport) {
        self.budgetCategory = BudgetCategory(id: groupReport.id) ?? .income
        super.init(groupReport: groupReport)
    }
    
}

extension BudgetCategoryGroupReport: Reportable {
    
    /// The grouping type of the model
    public static var grouping: ReportGrouping {
        return .budgetCategory
    }
    
}

/// Transaction Category Group Report
public final class TransactionCategoryGroupReport: GroupReport {
    
    /// The transaction category ID of the report
    public var id: Int64
    
    /// Initializer from a group report object
    public override init(groupReport: APIGroupReport) {
        self.id = groupReport.id
        super.init(groupReport: groupReport)
    }
    
}

extension TransactionCategoryGroupReport: Reportable {
    
    /// The grouping type of the model
    public static var grouping: ReportGrouping {
        return .transactionCategory
    }
    
}

/// Tag Group Report
public final class TagGroupReport: GroupReport {
    
    /// Initializer from a group report object
    public override init(groupReport: APIGroupReport) {
        super.init(groupReport: groupReport)
    }
    
}

extension TagGroupReport: Reportable {
    
    /// The grouping type of the model
    public static var grouping: ReportGrouping {
        return .tag
    }
    
}

/// Merchant Group Report
public final class MerchantGroupReport: GroupReport {
    
    /// The merchant ID of the report
    public var id: Int64
    
    /// Initializer from a group report object
    public override init(groupReport: APIGroupReport) {
        self.id = groupReport.id
        super.init(groupReport: groupReport)
    }
    
}

extension MerchantGroupReport: Reportable {
    
    /// The grouping type of the model
    public static var grouping: ReportGrouping {
        return .merchant
    }
    
}
