# Getting Started

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate FrolloSDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
git "git@bitbucket.org:frollo1/frollo-ios-sdk.git" ~> 3.0
```

Run `carthage update` to build the framework and drag the built `FrolloSDK.framework` and `Alamofire.framework` into your Xcode project.

### Swift Package Manager

*Coming Soon*

## Basic Usage

### Setup

Import the FrolloSDK and ensure you run setup with your tenant URL provided by us. Do not attempt to use any APIs before the setup completion handler returns. You will also need to pass in your custom authentication handler or use the default OAuth2 implementation.

```swift
import FrolloSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    /// OAuth2 Config

    let config = FrolloSDKConfiguration(authenticationType: .oAuth2(clientID: "<APPLICATION_CLIENT_ID>",
                                                                    redirectURL: URL(string: "<REDIRECT_URI>")!,
                                                                    authorizationEndpoint: URL(string: "https://id.frollo.us/oauth/authorize")!,
                                                                    tokenEndpoint: URL(string: "https://id.frollo.us/oauth/token")!),
                                        serverEndpoint: URL(string: "https://<API_TENANT>.frollo.us/api/v2/")!)

    /// Custom Authentication Config

    let customAuthentication = CustomAuthentication()
    let config = FrolloSDKConfiguration(authenticationType: .custom(authentication: customAuthentication),
                                            serverEndpoint: URL(string: "https://<API_TENANT>.frollo.us/api/v2/")!)

    FrolloSDK.shared.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success:
                    self.completeSetup(completion: completion)
            }
        }
```

### Authentication

Before any data can be refreshed for a user they must be authenticated first. You can check the logged in status of the user on the [Authentication](Classes/Authentication.html#/s:9FrolloSDK14AuthenticationC8loggedInSbvp) class.

```swift
if FrolloSDK.shared.authentication.loggedIn {
    showMainViewController()
} else {
    showLoginViewController()
}
```

If the user is not authenticated then the user must login or an access token must be provided by the Authentication class. Authentication can be done using OAuth2 or a custom implementation can be provided if you wish to manage the user's access token manually or share it with other APIs.

#### OAuth2 Authentication

Using OAuth2 based authentication Resource Owner Password Credential flow and Authorization Code with PKCE flow are supported. Identity Providers must be OpenID Connect compliant to use the in-built [OAuth2Authentication](Classes/OAuth2Authentication.html) authentication class. If using OAuth2 authentication you can use [defaultAuthentication](Classes/FrolloSDK.html#/s:9FrolloSDKAAC21defaultAuthenticationAA06OAuth2D0CSgvp)

##### ROPC Flow

Using the ROPC flow is the simplest and can be used if you are implementing the SDK in your own highly trusted first party application. All it requires is email and password and can be used in conjunction with a native UI.

See [loginUser(email:password:completion:)](Classes/OAuth2Authentication.html#/s:9FrolloSDK20OAuth2AuthenticationC9loginUser5email8password10completionySS_SSyAA11EmptyResultOys5Error_pGctF)

```swift
FrolloSDK.shared.defaultAuthentication?.loginUser(email: "jacob@example.com", password: "$uPer5ecr@t") { (result) in
    switch result {
        case .failure(let error):
            presentError(loginError.localizedDescription)
        case .success:
            self.completeLogin()
    }
}
```

##### Authorization Code with PKCE Flow

Authenticating the user using Authorization Code flow involves a couple of extra steps to configure. The first is to present the Safari View Controller to the user to take them through the web based authorization flow. The view controller this should be presented from must be passed to the SDK.

iOS see [loginUserUsingWeb(presenting:completion:)](Classes/OAuth2Authentication.html#/s:9FrolloSDK20OAuth2AuthenticationC17loginUserUsingWeb10completionyyAA11EmptyResultOys5Error_pGc_tF)

macOS see [loginUserUsingWeb(completion:)](Classes/OAuth2Authentication.html#/s:9FrolloSDK20OAuth2AuthenticationC17loginUserUsingWeb10completionyyAA11EmptyResultOys5Error_pGc_tF)

```swift
FrolloSDK.shared.defaultAuthentication?.loginUserUsingWeb(presenting: viewController) { (result) in
    switch result {
        case .failure(let error):
            presentError(loginError.localizedDescription)
        case .success:
            self.completeLogin()
    }
}
```

The second step is to pass the redirect URI deep link called by the authorization flow to the SDK to complete the login process and exchange the authorization code for a token. This should be done by implementing the following in your AppDelegate.swift for iOS. See [AppAuth](https://github.com/openid/AppAuth-iOS) for details on handling deep links on macOS.

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return FrolloSDK.shared.applicationOpen(url: url)
}
```

#### Custom Authentication

Custom authentication can be provided by conforming to the [Authentication](Protocols/Authentication.html) protocol and ensuring [refreshTokens(completion:)](Protocols/Authentication.html#/s:9FrolloSDK14AuthenticationP13refreshTokens10completionyyAA11EmptyResultOys5Error_pGcSg_tF) and calls to the delegate are implemented appropriately.

### Refreshing Data

After logging in your cache will be empty in the SDK. Refresh important data such as [Aggregation](Classes/Aggregation.html) immediately after login.

```swift
FrolloSDK.shared.aggregation.refreshProviders { (error) in
    if let refreshError = error {
        print(refreshError.localizedDescription)
    }
}
```

Alternatively refresh data on startup in an optimized way using [refreshData()](Classes/FrolloSDK.html#/s:9FrolloSDKAAC11refreshDatayyF) on the main SDK. This will refresh important user data first, delaying less important ones until later.

```swift
FrolloSDK.shared.refreshData()
```

### Retrieving Cached Data

Fetching objects from the cache store is easy. Just setup a predicate and a sort descriptor to filter what items you want and call the SDK.

```swift
// Get the main thread view context
let context = FrolloSDK.shared.database.viewContext

// Filter transactions by a specific account
let predicate = NSPredicate(format: #keyPath(Transaction.accountID) + " == %ld", argumentArray: [accountID])

// Sort by date, most recent first
let sortDescriptors = [NSSortDescriptor(key: #keyPath(Transaction.transactionDateString), ascending: false)]

// Fetch the transactions
let transactions = FrolloSDK.shared.aggregation.transactions(context: context, filteredBy: predicate, sortedBy: sortDescriptors)
```

### Deep Link Handler

Deep links should be forwarded to the SDK to support web based OAuth2 login and other links that can affect application behaviour.

#### iOS

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return FrolloSDK.shared.applicationOpen(url: url)
}
```

#### macOS

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  // Register for GetURL events.
  NSAppleEventManager.sharedAppleEventManager.setEventHandler(self, andSelector: #selector(handleGetURLEvent:withReplyEvent:), forEventClass: kInternetEventClass, andEventID:kAEGetURL)
}

func handleGetURLEvent(event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
  let URLString = event.paramDescriptorForKeyword(keyDirectObject)
  let url = URL(string: URLString))
  FrolloSDK.shared.applicationOpen(url: url
}
```

### Lifecyle Handlers (Optional)

Optionally implement the lifecycle handlers in your app delegate to ensure FrolloSDK can keep cached data fresh when suspending and resuming the app.

```swift
func applicationDidEnterBackground(_ application: UIApplication) {
    FrolloSDK.shared.applicationDidEnterBackground()
}

func applicationWillEnterForeground(_ application: UIApplication) {
    FrolloSDK.shared.applicationWillEnterForeground()
}
```




