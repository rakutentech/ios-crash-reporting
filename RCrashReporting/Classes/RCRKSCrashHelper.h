#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * KSCrashHelper.h
 * Class is used to to help retrieve crash reports created by KSCrash.
 */
@interface RCRKSCrashHelper : NSObject

/**
 * Returns array of dictionaries containing KSCrash JSON-formatted crash reports.
 */
+ (NSArray <NSDictionary *> *)getArrayOfCrashReports;

@end

NS_ASSUME_NONNULL_END
