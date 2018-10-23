//
//  User+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 24/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

public class User: NSManagedObject {
    
    public struct FeatureFlag: Codable, Equatable {
        let enabled: Bool
        let feature: String
    }
    
    public enum Gender: String, Codable {
        case female
        case male
        case other
    }
    
    public enum HouseholdType: String, Codable {
        case couple
        case coupleWithChildren = "couple_with_kids"
        case single
        case singleWithChildren = "single_parent"
    }
    
    public enum Industry: String, Codable {
        case accommodationAndFoodServices = "accommodation_and_food_services"
        case administrativeAndSupportServices = "administrative_and_support_services"
        case artsAndRecreationsServices = "arts_and_recreations_services"
        case construction = "construction"
        case educationAndTraining = "education_and_training"
        case electricityGasWaterAndWasteServices = "electricity_gas_water_and_waste_services"
        case financialAndInsuranceServices = "financial_and_insurance_services"
        case healthCareAndSocialAssistance = "health_care_and_social_assistance"
        case informationMediaAndTelecommunications = "information_media_and_telecommunications"
        case manufacturing = "manufacturing"
        case mining = "mining"
        case otherServices = "other_services"
        case professionalScientificAndTechnicalServices = "professional_scientific_and_technical_services"
        case publicAdministrationAndSafety = "public_administration_and_safety"
        case rentalHiringAndRealEstateServices = "rental_hiring_and_real_estate_services"
        case retailTrade = "retail_trade"
        case transportPostalAndWarehousing = "transport_postal_and_warehousing"
        case wholesaleTrade = "wholesale_trade"
    }
    
    public enum Occupation: String, Codable {
        case clericalAndAdministrativeWorkers = "clerical_and_administrative_workers"
        case communityAndPersonalServiceWorkers = "community_and_personal_service_workers"
        case labourers = "labourers"
        case machineryOperatorsAndDrivers = "machinery_operators_and_drivers"
        case managers = "managers"
        case professionals = "professionals"
        case salesWorkers = "sales_workers"
        case techniciansAndTradesWorkers = "technicians_and_trades_workers"
    }
    
    public enum Status: String, Codable {
        case accountAdded = "account_added"
        case active = "active"
        case budgetReady = "budget_ready"
        case inactive = "inactive"
        case registered
    }
    
    static let entityName = "User"
    
    public var features: [FeatureFlag]? {
        get {
            if let featureData = featuresRawValue {
                let decoder = JSONDecoder()
                
                do {
                    let features = try decoder.decode([FeatureFlag].self, from: featureData)
                    return features
                } catch {
                    Log.error(error.localizedDescription)
                }
            }
            return nil
        }
        set {
            let encoder = JSONEncoder()
            featuresRawValue = try? encoder.encode(newValue)
        }
    }
    
    public var gender: Gender? {
        get {
            if let rawGender = genderRawValue{
                return Gender(rawValue: rawGender)
            }
            return nil
        }
        set {
            genderRawValue = newValue?.rawValue
        }
    }
    
    public var householdType: HouseholdType? {
        get {
            if let rawHouseholdType = householdTypeRawValue {
                return HouseholdType(rawValue: rawHouseholdType)
            }
            return nil
        }
        set {
            householdTypeRawValue = newValue?.rawValue
        }
    }
    
    public var industry: Industry? {
        get {
            if let rawIndustry = industryRawValue {
                return Industry(rawValue: rawIndustry)
            }
            return nil
        }
        set {
            industryRawValue = newValue?.rawValue
        }
    }
    
    public var occupation: Occupation? {
        get {
            if let rawOccupation = occupationRawValue {
                return Occupation(rawValue: rawOccupation)
            }
            return nil
        }
        set {
            occupationRawValue = newValue?.rawValue
        }
    }
    
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue!)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    // MARK: - Updating from response
    
    internal func update(response: APIUserResponse) {
        userID = response.userID
        email = response.email
        firstName = response.firstName
        primaryCurrency = response.primaryCurrency
        status = response.status
        validPassword = response.validPassword
        
        facebookID = response.facebookID
        features = response.features
        gender = response.gender
        householdSize = response.householdSize ?? -1
        householdType = response.householdType
        industry = response.industry
        lastName = response.lastName
        occupation = response.occupation
        postcode = response.address?.postcode
    }
    
    // MARK: - Update request
    
    internal func updateRequest() -> APIUserUpdateRequest {
        var address: APIUserUpdateRequest.Address?
        if let code = postcode {
            address = APIUserUpdateRequest.Address(postcode: code)
        }
        
        return APIUserUpdateRequest(email: email!,
                                    firstName: firstName!,
                                    primaryCurrency: primaryCurrency!,
                                    address: address,
                                    dateOfBirth: dateOfBirth,
                                    gender: gender,
                                    householdSize: householdSize,
                                    householdType: householdType,
                                    industry: industry,
                                    lastName: lastName,
                                    occupation: occupation)
    }
    
}
