#import "RCRDeviceInformation.h"
#import "RCRRequestUtil.h"

@implementation RCRRequestUtil

+ (NSURLSessionConfiguration*)getSessionConfiguration
{
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Include subscription key in HTTP header.
    NSString* subscriptionKey = [RCRRequestUtil getSubscriptionKey];
    if (subscriptionKey.length)
    {
        sessionConfig.HTTPAdditionalHeaders = @{@"Ocp-Apim-Subscription-Key":subscriptionKey};
    }
    return sessionConfig;
}

+ (NSString*)getAppVersionAndBuild
{
    return [NSString stringWithFormat:@"%@_%@",
        [RCRDeviceInformation getAppVersion],
        [RCRDeviceInformation getBuildNumber]];
}

+ (void)printTroubleshootHelp:(NSException*)exception
{
    NSLog(@"Unfortunately CrashReporting has had an internal exception. Please contact the RCrashReporting team and attach the following log: %@", exception);
}

/**
 * Returns the Relay subscription key inside Info.plist.
 */
+ (NSString*)getSubscriptionKey
{
    NSBundle* appBundle = NSBundle.mainBundle;
    return [appBundle objectForInfoDictionaryKey:@"RPTSubscriptionKey"];
}

@end
