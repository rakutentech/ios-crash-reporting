[![Build Status](https://travis-ci.org/rakutentech/ios-crash-reporting.svg?branch=master)](https://travis-ci.org/rakutentech/ios-crash-reporting)
[![codecov](https://codecov.io/gh/rakutentech/ios-crash-reporting/branch/master/graph/badge.svg)](https://codecov.io/gh/rakutentech/ios-crash-reporting)


# Crash Reporting

The **Crash Reporting** module is a tool that records application crash logs and sends them to a backend on the next app launch. The backend processes the logs for easy viewing through a web portal.

## Getting started

This module supports iOS 8.0 and above. It has been tested on iOS 8.4 and above.

### Installing as CocoaPods pod

To use the module your `Podfile` should contain:

    source 'https://github.com/CocoaPods/Specs.git'

    pod 'RCrashReporting', :git => 'https://github.com/rakutentech/ios-crash-reporting.git'

Run `pod install` to install the module and its dependencies.

### Configuring

Currently we do not host any publicly accessible backend APIs.

You must specify the following values in your application's `info.plist` in order to use the module:

| Key | Value |
|------|------|
| `RPTSubscriptionKey` | Subscription key from Rakuten internal portal |
| `RPTRelayAppID` | Application ID from Rakuten internal portal |
| `RCRConfigAPIEndpoint` | Endpoint to fetch the module configuration |

## Contributing

See the [contributing guide](CONTRIBUTING.md) for details of how to participate in development of the module.

## Changelog

See the [changelog](CHANGELOG.md) for the new features, changes and bug fixes of the module versions.
