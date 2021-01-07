# Changelog

## 4.8.0

### Features

- Contacts

### Changes

- User details API  address, tax details
- User details Onboarding steps
- Remove tracking_type in budget

### Fixes

- Fixed crash in merchants
- Fixed passing legacy refresh token
- Fixed Alamofire valid empty response codes


## 4.7.0

### Features

- Payments API
- CDR Configuration API
- OTP endpoint protection
- Images API

### Changes

- Xcode 12 support
- API 2.11 upgrade
- Added support for CDR existing consent ID parameter

## 4.6.3

### Fixes

- Fixed crash in metadata for messages

## 4.6.2

### Changes

- Updated Alamofire dependency to 5.2.1

## 4.6.1

### Changes

- Added support for Sharing Stopped At field on Consents

## 4.6.0

### Features

- Included provider availability status
- Added consent object caching

### Fixes

- Fix for sending a push notification sent to SDK before setup has completed

## 4.5.1

### Features

- CDR Products List API
- Added CDR Product Object in Account
- Budget By Account

### Fixes

- Fixed various issues in CDR response
- Fixed an issue in budgets API creation

## 4.5.0

- Open Banking support

### Features

- CDR Consent support
- Automatically mark push notifications as read

## 4.4.1

### Fixes

- Fixed issue with refreshing cached merchants

## 4.4

- Transaction and Merchant Enhancements

### Features

- Transactions advanced filtering and searching
- Merchants searching
- Submit Consent

### Changes

- Transaction pagination improvements
- Goal and Budget Period tracking status renamed for clarity

## 4.3

- Budgeting and Reports Enhancements

### Features

- Budgeting
- Enhanced Reporting - breakdown by additional periods and other filters
- Enhancements to Surveys - generic metadata support and additional top level survey fields available

### Changes

- Removed caching of reports - this should now be managed at the application level
- Pagination of the merchants API

### Fixes

- Various fixes for crash reports
- Fixed issue with certificate pinning

## 4.2.1

### Changes

- Upgrade 3rd party dependencies to resolve conflicts

## 4.2

- Aggregation, Goals and Messages Ehancements

### Features

- Force a refresh of a provider account with the aggregator
- Refresh cached merchant data
- Goals generic metadata support
- Messages generic metadata support

### Changes

- Send app version in addition to SDK version in headers
- Messages supports expanded URL opening methods

### Fixes

- Transaction search API fix
- Access token subdomain validation fixed when appending tokens to requests

## 4.1.1

### Fixes

- Fix issue where user tags could be duplicated in the cache

## 4.1

- Pay Days

### Features

- Pay Days

### Changes

- Budget category apply all
- Goal enhancements

## 4.0

- Goals

### Features

- Goals

### Changes

- Improved custom authentication making it easier to implement
- API version 2.4 with support for client ID on register/reset password

### Fixes

- Fixed an issue where naming conflicts could cause an issue and not be easily resolved by using the module namespace. The `FrolloSDK` class was renamed to `Frollo` to allow `FrolloSDK.Authentication` for example to work.

## 3.0.0

- Custom Authentication

### Features

- Custom Authentication - Custom handling of authentication can be provided to the SDK
- Transaction Tagging

### Changes

- App Group support - a cache path can now be provided to the SDK to allow data to be shared between an App Group
- Core Data persistent history tracking - the cache will now track Core Data persistent history tracking to allow multiple targets to share one instance of the cache

## 2.1.6

### Changes

- Return provider account ID upon creation

## 2.1.5

### Changes

- Logout calls OAuth2 revoke token API

## 2.1.4

### Changes

- Migrate user to new identity provider

## 2.1.3

### Fixes

- Fix issue where audience was sent with refresh token

## 2.1.2

### Changes

- User profile - Register complete flag added, first name now optional

## 2.1.1

### Changes

- Allow custom parameters in authorization code flow

## 2.1.0

- Surveys

### Features

- Surveys
- Transaction Search

### Changes

- Improved handling of logged out status
- Transactions enhancements
- Swift 5 support

## 2.0.0

- OpenID Connect / OAuth2 Login

### Features

- OAuth2 based authentication using ROPC and Authorization Code flows

### Changes

- Improved completion handlers
- Aggregation enhancements

## 1.3.0

- Reports

### Features

- Account Balance Reports
- Current Transaction Reports
- History Transaction Reports

## 1.2.0

- Bills

### Features

- Bills
- Bill Payments

## 1.1.0

- User Engagement

### Features

- Events
- Messages
- Push Notifications

## 1.0.0

- Initial release

### Features

- Aggregation
- User Authentication
