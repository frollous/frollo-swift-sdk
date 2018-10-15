![Frollo Logo](https://www.frollo.us/wp-content/uploads/2017/12/Frollo_primary_logo_purple_RGB-copy.png)

# Frollo Swift SDK

**V1.0.0**

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)

## Features

- Authentication
- Aggregation
- User

## Requirements

- iOS 10.0+ / macOS 10.13+ / tvOS 10.0+ / watchOS 4.0+
- Xcode 10.0+
- Swift 4.2+
- Carthage or Swift Package Manager

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
github "Frollo/FrolloSDK" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `FrolloSDK.framework` and `Alamofire.framework` into your Xcode project.

### Swift Package Manager

*Coming Soon*