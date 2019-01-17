#import "RCRDeviceInformation.h"
#import "RCRRequestUtil.h"

#define RCR_EXPAND_AND_QUOTE0(s) #s
#define RCR_EXPAND_AND_QUOTE(s) RCR_EXPAND_AND_QUOTE0(s)

#ifndef RCR_SDK_VERSION
#define RCR_SDK_VERSION 0.0.0
#endif

NSString* const RCRSDKVersion = @ RCR_EXPAND_AND_QUOTE(RCR_SDK_VERSION);

@implementation RCRRequestUtil

+ (NSURLSessionConfiguration*)getSessionConfiguration
{
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Include subscription key in HTTP header.
    NSString* subscriptionKey = [NSBundle.mainBundle objectForInfoDictionaryKey:@"RPTSubscriptionKey"];
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

@end
