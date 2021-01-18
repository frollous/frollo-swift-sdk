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

/**
 UserKYC Model
 
 Holds information about the KYC
 */
public class UserKYC: Codable {
    
    /// Array of Addresses
    public var addresses: [Address]
    
    /// Object to hold information of  date of birth
    public var dateOfBirth: DateOfBirth
    
    /// gender
    public var gender: String
    
    /// mobile number
    public var mobile: String?
    
    /// Object to hold information of name
    public var name: Name
    
    /// Array of Identity documents
    public var identityDocuments: [IdentityDocument]
    
    /// initilizer
    init(addresses: [Address], dateOfBirth: DateOfBirth, gender: String, mobile: String?, name: Name, identityDocuments: [IdentityDocument]) {
        self.addresses = addresses
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.mobile = mobile
        self.name = name
        self.identityDocuments = identityDocuments
    }
    
    private enum CodingKeys: String, CodingKey {
        case addresses
        case dateOfBirth = "date_of_birth"
        case gender
        case mobile
        case name
        case identityDocuments = "identity_docs"
    }
    
    /**
     IdentitiDoc
     
     Object that holds information of any Identity document
     */
    public class IdentityDocument: Codable {
        
        /// Country of the document
        public var country: String?
        
        /// The expiry data of the document (if known) in YYYY-MM-DD format.
        public var idExpiry: String?
        
        /// The ID number of the document.
        public var idNumber: String
        
        /// The sub-type of identity document. Very document specific.
        public var idSubType: String?
        
        /// The type of identity document.
        public var idType: IDType
        
        /// Regional variant of the ID (e.g. VIC drivers licence).
        public var region: String?
        
        /// initilizer
        init(country: String?, idExpiry: String?, idNumber: String, idSubType: String?, idType: IDType, region: String?) {
            self.country = country
            self.idExpiry = idExpiry
            self.idNumber = idNumber
            self.idSubType = idSubType
            self.idType = idType
            self.region = region
        }
        
        private enum CodingKeys: String, CodingKey {
            case country
            case idExpiry = "id_expiry"
            case idNumber = "id_number"
            case idSubType = "id_sub_type"
            case idType = "id_type"
            case region
        }
        
        /// type of an ID
        public enum IDType: String, Codable {
            
            /// ID type other
            case other = "OTHER"
            
            /// ID type driver's licence
            case driverLicence = "DRIVERS_LICENCE"
            
            /// ID type passport
            case passport = "PASSPORT"
            
            /// ID type visa
            case visa = "VISA"
            
            /// ID type immigration
            case immigration = "IMMIGRATION"
            
            /// ID type national ID
            case nationalID = "NATIONAL_ID"
            
            /// ID type tax ID
            case taxID = "TAX_ID"
            
            /// ID type national health ID
            case nationalHealthID = "NATIONAL_HEALTH_ID"
            
            /// ID type concession
            case concession = "CONCESSION"
            
            /// ID type health concession
            case healthConcession = "HEALTH_CONCESSION"
            
            /// ID type pension
            case pension = "PENSION"
            
            /// ID type military ID
            case militaryID = "MILITARY_ID"
            
            /// ID type birth certificate
            case birthCert = "BIRTH_CERT"
            
            /// ID type citizenship
            case citizenship = "CITIZENSHIP"
            
            /// ID type marriage certificate
            case marriageCert = "MARRIAGE_CERT"
            
            /// ID type death certificate
            case deathCert = "DEATH_CERT"
            
            /// ID type name change
            case nameChange = "NAME_CHANGE"
            
            /// ID type utility bill
            case utilityBill = "UTILITY_BILL"
            
            /// ID type bank statement
            case bankStatement = "BANK_STATEMENT"
            
            /// ID type intent proof
            case intentProof = "INTENT_PROOF"
            
            /// ID type assestation
            case assestation = "ATTESTATION"
            
            /// ID type self Image
            case selfImage = "SELF_IMAGE"
            
            /// ID type email address
            case emailAddress = "EMAIL_ADDRESS"
            
            /// ID type msisdn
            case msisdn = "MSISDN"
            
            /// ID type device
            case device = "DEVICE"
            
        }
        
    }
    
    /**
     Name
     
     Object to hold information of Name
     */
    public class Name: Codable {
        
        /// In some cases, the name will need to be supplied in “long form”, such as when it is determined from a document scan, or is un-parsable in some way. The service will attempt to convert it to it’s constituent parts where possible.
        public var displayName: String?
        
        /// Family name / Surname of the individual.
        public var familyName: String?
        
        /// First / Given name.
        public var givenName: String?
        
        /// Mr/Ms/Dr/Dame/Dato/etc.
        public var honourific: String?
        
        /// Middle name(s) / Initials.
        public var middleName: String?
        
        /// initilizer
        init(displayName: String?, familyName: String?, givenName: String?, honourific: String?, middleName: String?) {
            self.displayName = displayName
            self.familyName = familyName
            self.givenName = givenName
            self.honourific = honourific
            self.middleName = middleName
        }
        
        private enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case familyName = "family_name"
            case givenName = "given_name"
            case honourific
            case middleName = "middle_name"
        }
        
    }
    
    /**
     Date Of Birth
     
     Object to hold information of Date of birth
     */
    public class DateOfBirth: Codable {
        
        /// Date of Birth in YYYY-MM-DD format.
        public var dateOfBirth: String?
        
        /// Year of birth or “unknown”. This will be autoextracted if dateOfBirth is supplied.
        public var yearOfBirth: String?
        
        /// initilizer
        public init(dateOfBirth: String?, yearOfBirth: String?) {
            self.dateOfBirth = dateOfBirth
            self.yearOfBirth = yearOfBirth
        }
        
        private enum CodingKeys: String, CodingKey {
            case dateOfBirth = "date_of_birth"
            case yearOfBirth = "year_of_birth"
        }
        
    }
}

/**
 KYC Status
 */
public class UserKYCStatus: Codable {
    
    /// KYC status
    public var status: String
    
    /// initilizer
    init(status: String) {
        self.status = status
    }
    
    private enum CodingKeys: String, CodingKey {
        case status
    }
}
