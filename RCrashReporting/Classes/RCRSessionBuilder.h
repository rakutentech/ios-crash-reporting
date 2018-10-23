#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * SessionBuilder.h
 * Class is used to do help build sessions by formatting all the data
 * before sending it to the backend.
 */
@interface RCRSessionBuilder : NSObject

/**
 * Invokes on bootup to parse through crash reports, if available, and sends to backend.
 */
+ (void)setUpSession;

/**
 * Append object with timestamp for both background/foreground and save to plist.
 */
+ (void)appendLifecycleTimestamps;

/**
 * @returns current time in miliseconds since Janurary 1, 1970.
 */
+ (long)getCurrentTime;

/**
 * Invokes when app goes into foreground.
 */
+ (void)enterForeground;

/**
 * Invokes when app goes into background.
 */
+ (void)enterBackground;

/**
 * Clear plist(cache) file of the sessions.
 */
+ (void)clearPListSessionList;

/**
 * @returns boolean true if NSUserDefault file exceeds specified file size so that it can be flushed.
 */
+ (BOOL)isLocalFileTooBig;

@end

NS_ASSUME_NONNULL_END
