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
git "git@bitbucket.org:frollo1/frollo-ios-sdk.git" ~> 2.0
```

Run `carthage update` to build the framework and drag the built `FrolloSDK.framework` and `Alamofire.framework` into your Xcode project.

### Swift Package Manager

*Coming Soon*

## Basic Usage

### Setup

Import the FrolloSDK and ensure you run setup with your tenant URL provided by us. Do not attempt to use any APIs before the setup completion handler returns.

```swift
import FrolloSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
    let clientID = "<APPLICATION_CLIENT_ID>"
    let redirectURL = URL(string: "<REDIRECT_URI>")!
    let authorizationURL = URL(string: "https://id.frollo.us/oauth/authorize")!
    let tokenURL = URL(string: "https://id.frollo.us/oauth/token")!
    let serverURL = URL(string: "https://<API_TENANT>.frollo.us/api/v2/")!
        
    let config = FrolloSDKConfiguration(clientID: clientID, redirectURL: redirectURL, authorizationEndpoint: authorizationURL, tokenEndpoint: tokenURL, serverEndpoint: serverURL)
        
    FrolloSDK.shared.setup(configuration: config) { (result) in
        switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success:
                DispatchQueue.main.async {
                    self.completeStartup()
                }
        }
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

If the user is not authenticated the [loginUser](Classes/Authentication.html#/s:9FrolloSDK14AuthenticationC9loginUser6method5email8password6userID0I5Token10completionyAC8AuthTypeO_SSSgA3Mys5Error_pSgctF) API should be called with the user's credentials.

```swift
FrolloSDK.shared.authentication.loginUser(method: .email, email: "jacob@example.com", password: "$uPer5ecr@t") { (error) in
    if let loginError = error {
        presentError(loginError.localizedDescription)
    } else {
        showMainViewController()
    }
}
```

### Refreshing Data

After logging in your cache will be empty in the SDK. Refresh important data such as [Aggregation](Classes/Aggregation.html) immediately after login.

```swift
FrolloSDK.shared.aggregation.refreshProviders { (error) in
    if let refreshError = error {
        print(refreshError.localizedDescription)
    }
}
```

Alternatively refresh data on startup in an optimized way using [refreshData()]() on the main SDK. This will refresh important user data first, delaying less important ones until later.

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




