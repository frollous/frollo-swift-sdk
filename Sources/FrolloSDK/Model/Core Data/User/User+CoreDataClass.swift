//
// Copyright © 2018 Frollo. All rights reserved.
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
//

import CoreData
import Foundation

/**
 User Model
 
 Stores information about the user and their profile
 */
public class User: NSManagedObject {
    /**
     Feature Flags
     
     Represents features which are available to the user
     */
    public struct FeatureFlag: Codable, Equatable {
        
        /// Feature enabled or disabled
        public let enabled: Bool
        
        /// Feature name
        public let feature: String
        
    }
    
    /**
     Gender
     
     Represents the gender of the user
     */
    public enum Gender: String, Codable {
        
        /// Female
        case female
        
        /// Male
        case male
        
        /// Other or unspecified
        case other
        
    }
    
    /**
     Household Type
     
     Represents the make up of the household
     */
    public enum HouseholdType: String, Codable {
        
        /// Couple with no dependents
        case couple
        
        /// Couple with children
        case coupleWithChildren = "couple_with_kids"
        
        /// Single with no dependents
        case single
        
        /// Single with children
        case singleWithChildren = "single_parent"
        
    }
    
    /**
     Industry
     
     Represents the industry the user works in
     */
    public enum Industry: String, Codable {
        
        /// Accommodation and Food Services
        case accommodationAndFoodServices = "accommodation_and_food_services"
        
        /// Administrative and Support Services
        case administrativeAndSupportServices = "administrative_and_support_services"
        
        /// Arts and Recreation Services
        case artsAndRecreationsServices = "arts_and_recreations_services"
        
        /// Construction
        case construction
        
        /// Education and Training
        case educationAndTraining = "education_and_training"
        
        /// Electricity, Gas, Water and Waste Services
        case electricityGasWaterAndWasteServices = "electricity_gas_water_and_waste_services"
        
        /// Financial and Insurance Services
        case financialAndInsuranceServices = "financial_and_insurance_services"
        
        /// Healthcare and Social Assistance
        case healthCareAndSocialAssistance = "health_care_and_social_assistance"
        
        /// Information, Media and Telecommunications
        case informationMediaAndTelecommunications = "information_media_and_telecommunications"
        
        /// Manufacturing
        case manufacturing
        
        /// Mining
        case mining
        
        /// Other Services
        case otherServices = "other_services"
        
        /// Professional, Scientific and Technical Services
        case professionalScientificAndTechnicalServices = "professional_scientific_and_technical_services"
        
        /// Public Administration and Safety
        case publicAdministrationAndSafety = "public_administration_and_safety"
        
        /// Rental, Hiring and Real Estate Services
        case rentalHiringAndRealEstateServices = "rental_hiring_and_real_estate_services"
        
        /// Retail Trade
        case retailTrade = "retail_trade"
        
        /// Transport, Postal and Warehousing
        case transportPostalAndWarehousing = "transport_postal_and_warehousing"
        
        /// Wholesale Trade
        case wholesaleTrade = "wholesale_trade"
        
    }
    
    /**
     Occupation
     
     Represents occupation of the user
     */
    public enum Occupation: String, Codable {
        
        /// Clerical and Administrative Workers
        case clericalAndAdministrativeWorkers = "clerical_and_administrative_workers"
        
        /// Community and Personal Service Workers
        case communityAndPersonalServiceWorkers = "community_and_personal_service_workers"
        
        /// Labourers
        case labourers
        
        /// Machinery Operators and Drivers
        case machineryOperatorsAndDrivers = "machinery_operators_and_drivers"
        
        /// Managers
        case managers
        
        /// Professionals
        case professionals
        
        /// Sales Workers
        case salesWorkers = "sales_workers"
        
        /// Technicians and Trades Workers
        case techniciansAndTradesWorkers = "technicians_and_trades_workers"
        
    }
    
    /**
     User Status
     
     Status indicating the current state of the user in the onboarding and setting up process.
     */
    public enum Status: String, Codable {
        
        /// An aggregation account has been added
        case accountAdded = "account_added"
        
        /// The user has completed all setup activities and is now fully active. This includes adding an account and setting a budget
        case active
        
        /// The user has connected an aggregation account and there is now enough data for the user to setup their budget.
        case budgetReady = "budget_ready"
        
        /// The user is inactive as they have previously added an account but now have no aggregation accounts linked. Similar to `registered`
        case inactive
        
        /// The user has registered but not yet completed any setup activities such as adding an aggregation account.
        case registered
        
    }
    
    /**
     Otp  Method Type
     
     Method by which the OTP should be sent to the user's registered mobile number
     */
    public enum OtpMethodType: String, Codable, CaseIterable {
        /// OTP will be sent via SMS mode
        case sms
    }
    
    /**
     Register Steps
     
     Represents registration steps which are required
     */
    public struct RegisterStep: Codable, Equatable {
        
        /// Step key
        public let key: String
        
        /// Step index
        public let index: Int
        
        /// Step required flag
        public let required: Bool
        
        /// Step completed flag
        public let completed: Bool
        
    }
    
    /// Core Data entity description name
    static let entityName = "User"
    
    /// An array of `FeatureFlag` decoded from a json array stored in the database. (Optional)
    public var features: [FeatureFlag]? {
        get {
            if let featureData = featuresRawValue {
                let decoder = JSONDecoder()
                
                do {
                    let features = try decoder.decode([FeatureFlag].self, from: featureData)
                    return features
                } catch {
                    error.logError()
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                do {
                    featuresRawValue = try encoder.encode(newRawValue)
                } catch {
                    featuresRawValue = nil
                }
            } else {
                featuresRawValue = nil
            }
        }
    }
    
    /// Gender of the user (optional)
    public var gender: Gender? {
        get {
            if let rawGender = genderRawValue {
                return Gender(rawValue: rawGender)
            }
            return nil
        }
        set {
            genderRawValue = newValue?.rawValue
        }
    }
    
    /// Household type of the user (optional)
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
    
    /// Industry the user works in (optional)
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
    
    /// Occupation of the user (optional)
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
    
    /// Status of the user's account
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// An array of `RegisterStep` decoded from a json array stored in the database. (Optional)
    public var registerSteps: [RegisterStep]? {
        get {
            if let featureData = registerStepsRawValue {
                let decoder = JSONDecoder()
                
                do {
                    let features = try decoder.decode([RegisterStep].self, from: featureData)
                    return features
                } catch {
                    error.logError()
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                do {
                    registerStepsRawValue = try encoder.encode(newRawValue)
                } catch {
                    registerStepsRawValue = nil
                }
            } else {
                registerStepsRawValue = nil
            }
        }
    }
    
    /// Address of user (optional)
    public var address: Address? {
        get {
            if let addressData = addressRawValue {
                let decoder = JSONDecoder()
                
                do {
                    let address = try decoder.decode(Address.self, from: addressData)
                    return address
                } catch {
                    error.logError()
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                do {
                    addressRawValue = try encoder.encode(newRawValue)
                } catch {
                    addressRawValue = nil
                }
            } else {
                addressRawValue = nil
            }
        }
    }
    
    /// Mailing Address of user (optional)
    public var mailingAddress: Address? {
        get {
            if let mailingAddressData = mailingAddressRawValue {
                let decoder = JSONDecoder()
                
                do {
                    let mailingAddress = try decoder.decode(Address.self, from: mailingAddressData)
                    return mailingAddress
                } catch {
                    error.logError()
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                do {
                    mailingAddressRawValue = try encoder.encode(newRawValue)
                } catch {
                    mailingAddressRawValue = nil
                }
            } else {
                mailingAddressRawValue = nil
            }
        }
    }
    
    // MARK: - Updating from response
    
    internal func update(response: APIUserResponse) {
        // Required properties
        userID = response.userID
        email = response.email
        primaryCurrency = response.primaryCurrency
        status = response.status
        validPassword = response.validPassword
        emailVerified = response.emailVerified
        
        // Optional properties
        address = response.address
        mailingAddress = response.mailingAddress
        attributionAdGroup = response.attribution?.adGroup
        attributionCampaign = response.attribution?.campaign
        attributionCreative = response.attribution?.creative
        attributionNetwork = response.attribution?.network
        dateOfBirth = response.dateOfBirth
        facebookID = response.facebookID
        features = response.features
        firstName = response.firstName
        foreignTax = response.foreignTax ?? false
        gender = response.gender
        householdSize = response.householdSize ?? -1
        householdType = response.householdType
        industry = response.industry
        lastName = response.lastName
        mobileNumber = response.mobileNumber
        occupation = response.occupation
        registerSteps = response.registerSteps
        taxResidency = response.taxResidency
        tfn = response.tfn
        tin = response.tfn
    }
    
    // MARK: - Update request
    
    internal func updateRequest() -> APIUserUpdateRequest {
        
        var attribution: APIUserUpdateRequest.Attribution?
        if attributionAdGroup != nil || attributionCampaign != nil || attributionCreative != nil || attributionNetwork != nil {
            attribution = APIUserUpdateRequest.Attribution(adGroup: attributionAdGroup,
                                                           campaign: attributionCampaign,
                                                           creative: attributionCreative,
                                                           network: attributionNetwork)
        }
        
        return APIUserUpdateRequest(email: email,
                                    primaryCurrency: primaryCurrency,
                                    address: address?.isValid() ?? false ? address : nil,
                                    mailingAddress: mailingAddress?.isValid() ?? false ? mailingAddress : nil,
                                    attribution: attribution,
                                    dateOfBirth: dateOfBirth,
                                    firstName: firstName,
                                    foreignTax: foreignTax,
                                    gender: gender,
                                    householdSize: householdSize,
                                    householdType: householdType,
                                    industry: industry,
                                    lastName: lastName,
                                    mobileNumber: mobileNumber,
                                    occupation: occupation,
                                    taxResidency: taxResidency,
                                    tfn: tfn,
                                    tin: tin)
    }
    
}
