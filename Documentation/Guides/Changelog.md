# Changelog

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
