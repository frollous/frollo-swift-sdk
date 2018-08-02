//
//  AccountRefreshStatus.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

public enum AccountRefreshStatus: String, Codable {
    case success
    case adding
    case updating
    case needsAction = "needs_action"
    case failed
}

public enum AccountRefreshSubStatus: String, Codable {
    case success
    case partialSuccess = "partial_success"
    case inputRequired = "input_required"
    case providerSiteAction = "provider_site_action"
    case reloginRequired = "relogin_required"
    case temporaryFailure = "temporary_failure"
    case permanentFailure = "permanent_failure"
    case lastNameRequired = "last_name_required"
}

public enum AccountRefreshAdditionalStatus: String, Codable {
    case acceptSplash = "accept_splash"
    case acceptTermsConditions = "accept_terms_conditions"
    case accountClosed = "account_closed"
    case accountLocked = "account_locked"
    case accountNotFound = "account_not_found"
    case accountNotSupported = "account_not_supported"
    case additionalLogin = "additional_login"
    case aggregationBeta = "aggregator_beta"
    case aggregationError = "aggregator_error"
    case invalidCredentials = "invalid_credentials"
    case invalidLanguage = "invalid_language"
    case loginCancelled = "login_cancelled"
    case logoutRequired = "logout_required"
    case mfaEnrollmentNeeded = "mfa_enrollment_needed"
    case mfaFailed = "mfa_failed"
    case mfaInvalidToken = "mfa_invalid_token"
    case mfaNeeded = "mfa_needed"
    case mfaTimeout = "mfa_timeout"
    case passwordExpired = "password_expired"
    case registrationDuplicate = "registration_duplicate"
    case registrationFailed = "registration_failed"
    case registrationIncomplete = "registration_incomplete"
    case registrationInvalid = "registration_invalid"
    case siteClosed = "site_closed"
    case siteError = "site_error"
    case siteUnsupported = "site_unsupported"
    case unknownError = "unknown_error"
    case verifyCredentials = "verify_credentials"
    case verifyPersonalDetails = "verify_personal_details"
}

