//
//  Provider+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension Provider {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Provider> {
        return NSFetchRequest<Provider>(entityName: "Provider")
    }

    @NSManaged public var authTypeRawValue: String?
    @NSManaged public var baseURLString: String?
    @NSManaged public var containerBank: Bool
    @NSManaged public var containerBill: Bool
    @NSManaged public var containerCreditCard: Bool
    @NSManaged public var containerCreditScore: Bool
    @NSManaged public var containerInsurance: Bool
    @NSManaged public var containerInvestment: Bool
    @NSManaged public var containerLoan: Bool
    @NSManaged public var containerRealEstate: Bool
    @NSManaged public var containerReward: Bool
    @NSManaged public var containerUnknown: Bool
    @NSManaged public var encryptionAlias: String?
    @NSManaged public var encryptionPublicKey: String?
    @NSManaged public var encryptionTypeRawValue: String?
    @NSManaged public var forgotPasswordURLString: String?
    @NSManaged public var helpMessage: String?
    @NSManaged public var largeLogoURLString: String?
    @NSManaged public var loginFormRawValue: Data?
    @NSManaged public var loginHelpMessage: String?
    @NSManaged public var loginURLString: String?
    @NSManaged public var mfaTypeRawValue: String?
    @NSManaged public var name: String?
    @NSManaged public var oAuthSite: Bool
    @NSManaged public var popular: Bool
    @NSManaged public var providerID: Int64
    @NSManaged public var smallLogoURLString: String?
    @NSManaged public var statusRawValue: String?
    @NSManaged public var providerAccounts: Set<ProviderAccount>?

}

// MARK: Generated accessors for providerAccounts
extension Provider {

    @objc(addProviderAccountsObject:)
    @NSManaged public func addToProviderAccounts(_ value: ProviderAccount)

    @objc(removeProviderAccountsObject:)
    @NSManaged public func removeFromProviderAccounts(_ value: ProviderAccount)

    @objc(addProviderAccounts:)
    @NSManaged public func addToProviderAccounts(_ values: Set<ProviderAccount>)

    @objc(removeProviderAccounts:)
    @NSManaged public func removeFromProviderAccounts(_ values: Set<ProviderAccount>)

}
