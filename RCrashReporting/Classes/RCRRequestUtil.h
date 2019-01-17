#import <Foundation/Foundation.h>

extern NSString* const RCRSDKVersion;

NS_ASSUME_NONNULL_BEGIN

/**
 * RequestUtil.h
 * Class is used to provide helper methods for classes that handles HTTP requests.
 * Currently can retrieve Relay subscription key from Info.plist and set the sub
 * key into HTTP header.
 */
@interface RCRRequestUtil : NSObject

/**
 * Returns NSURLSessionConfiguration with default settings along with
 * Relay subscription key as a HTTP header if available.
 */
+ (NSURLSessionConfiguration*)getSessionConfiguration;

/**
 * Returns string of app version and build number together. E.G "1.0_21"
 */
 + (NSString*)getAppVersionAndBuild;

/**
 * Params exception is the exception caught by try-catch.
 * This method is invoked in the catch clause to print out crash
 * details for end-developers to help troubleshoot and provide
 * further assistance by contacting the CrashReporting dev team.
 */
+ (void)printTroubleshootHelp:(NSException*)exception;

@end

NS_ASSUME_NONNULL_END
