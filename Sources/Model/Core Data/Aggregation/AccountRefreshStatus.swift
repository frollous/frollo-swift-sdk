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

import Foundation

/**
 Account Refresh Status
 
 High level indication on the aggregator refresh of an account. Use this to determine if there's an issue.
 */
public enum AccountRefreshStatus: String, Codable {
    
    /// Success. The account was refreshed without issue
    case success
    
    /// Adding. The user has just added the account and the aggregator is fetching data
    case adding
    
    /// Updating. The account data is currently being updated.
    case updating
    
    /// Needs Action. The user needs to take an additional step to complete the latest update attempt. See `AccountRefreshSubStatus`
    case needsAction = "needs_action"
    
    /// Failed. The last update failed, the user may need to take an action or wait for the problem to be solved. See `AccountRefreshAdditionalStatus`
    case failed
}

/**
 Account Refresh Sub Status
 
 Sub status of what the issue with the account is. Use this to determine an appropriate action for the user to take to fix the issue.
 */
public enum AccountRefreshSubStatus: String, Codable {
    
    /// Success. Last update completed successfully
    case success
    
    /// Partial Success. Usually associated with a `ProviderAccount`, one or more `Account` refreshed successfully but others had issues
    case partialSuccess = "partial_success"
    
    /// Input Required. Additional information is required from the user in the form of a `loginForm` on the `ProviderAccount`
    case inputRequired = "input_required"
    
    /// Provider Site Action. The user needs to go to the website of the `Provider` and complete some action. See `AccountRefreshAdditionalStatus`
    case providerSiteAction = "provider_site_action"
    
    /// Relogin Required. The login details were incorrect or changed. The user needs to re-enter their details in the `Provider` `loginForm`
    case reloginRequired = "relogin_required"
    
    /// Temporary Failure. The refresh of the provider failed for a temporary reason. This will generally automatically be resolved at the next refresh.
    case temporaryFailure = "temporary_failure"
    
    /// Permanent Failure. The refresh failed permanently due to a reason that cannot be rectified. Usually due to an account being closed.
    case permanentFailure = "permanent_failure"
    
    /// Last Name Required. Used for credit score, if the user is missing a last name on their profile, it needs to be updated.
    case lastNameRequired = "last_name_required"
    
}

/**
 Account Refresh Additional Status
 
 Additional details on what issue occurred with the account. Use this to provide instructions and context to the user.
 */
public enum AccountRefreshAdditionalStatus: String, Codable {
    
    /// Accept Splash. The user needs to login to the `Provider` website and dismiss a modal popup
    case acceptSplash = "accept_splash"
    
    /// Accept Terms & Conditions. The user needs to login to the `Provider` website and accept the update terms & conditions
    case acceptTermsConditions = "accept_terms_conditions"
    
    /// Account Closed. The account has been closed so no data is available.
    case accountClosed = "account_closed"
    
    /// Account Locked. The account has been locked and the user will need to resolve this with the `Provider`
    case accountLocked = "account_locked"
    
    /// Account Not Found. No accounts were found when logging into the `Provider`
    case accountNotFound = "account_not_found"
    
    /// Account Not Supported. The account found on the `Provider` is not supported currently.
    case accountNotSupported = "account_not_supported"
    
    /// Additional Login. Additional information needed from the user. Usually MFA or captcha.
    case additionalLogin = "additional_login"
    
    /// Aggregation Beta. Refresh may be incomplete or failed as work to support the `Provider` is still in progress. Ensure user leaves the account in this state to help the process of adding an account
    case aggregationBeta = "aggregator_beta"
    
    /// Aggregation Error. The aggregator encountered an issue refreshing the site. This should get automatically resolved.
    case aggregationError = "aggregator_error"
    
    /// Invalid Credentials. The user needs to provide login details again.
    case invalidCredentials = "invalid_credentials"
    
    /// Invalid Language. The `Provider` account is set to an unsupported language by the aggregator.
    case invalidLanguage = "invalid_language"
    
    /// Login Cancelled. Login process was cancelled by the user. Try again.
    case loginCancelled = "login_cancelled"
    
    /// Logout Required. The user is logged in at another location and will need to logout for the refresh to succeed.
    case logoutRequired = "logout_required"
    
    /// MFA Enrollment Needed. MFA has not been setup by the user. This must be done through the `Provider` website
    case mfaEnrollmentNeeded = "mfa_enrollment_needed"
    
    /// MFA Failed. The MFA login failed. Try again
    case mfaFailed = "mfa_failed"
    
    /// MFA Invalid Token. The user provided an invalid MFA token and will need to login again
    case mfaInvalidToken = "mfa_invalid_token"
    
    /// MFA Needed. User needs to provide details for the MFA login form on `ProviderAccount`
    case mfaNeeded = "mfa_needed"
    
    /// MFA Timeout. User did not respond to MFA request quick enough. Consider displaying `ProviderLoginForm.mfaTimeout` to the user
    case mfaTimeout = "mfa_timeout"
    
    /// Password Expired. The user needs to visit the `Provider` website and update their password, then link to the app again.
    case passwordExpired = "password_expired"
    
    /// Registration Duplicate
    case registrationDuplicate = "registration_duplicate"
    
    /// Registration Failed. The user failed to register with the `Provider` properly
    case registrationFailed = "registration_failed"
    
    /// Registration Incomplete. The user hasn't completed their account setup with the `Provider` properly
    case registrationIncomplete = "registration_incomplete"
    
    /// Registration Invalid. The user's account with the `Provider` has an issue that needs to be recitifed on their website
    case registrationInvalid = "registration_invalid"
    
    /// Site Closed. The `Provider` website has shutdown and is no longer supported.
    case siteClosed = "site_closed"
    
    /// Site Error. An error occurred at the `Provider` website and will need to be resolved by the provider themselves
    case siteError = "site_error"
    
    /// Site Unsupported. The `Provider` site is no longer supported
    case siteUnsupported = "site_unsupported"
    
    /// Unknown Error
    case unknownError = "unknown_error"
    
    /// Verify Credentials. The user need to visit the `Provider` website to confirm their credentials.
    case verifyCredentials = "verify_credentials"
    
    /// Verify Personal Details. The user need to visit the `Provider` website to confirm their personal details.
    case verifyPersonalDetails = "verify_personal_details"
    
}
