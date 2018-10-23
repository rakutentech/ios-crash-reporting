#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * CrashReporting.h
 * Class is used to initialize everything at bootup including:
 * uncaught exception handler, signal handler, background listener, and service queue.
 */
@interface RCrashReporting : NSObject

/**
 * NSObject method that is invoked when a class is added to runtime.
 */
+ (void)load;

/**
 * Tells the delegate that the app is about to become inactive.
 * Invoked when application goes to background.
 */
+ (void)appWillResignActive;

/**
 * Tells the delegate that the app has become active.
 * Invoked when application goes to foreground.
 */
+ (void)appDidBecomeActive;

/**
 * Tells the delegate when the app is about to terminate.
 * Invoked when application is terminated.
 * Does not invoke if forcefully terminated.
 */
+ (void)appWillTerminate;

/**
 * Returns boolean of if install event was sent successfully or not.
 */
+ (BOOL)isFirstInstallEventSent;

/**
 * Create dispatch queue to be used by the CrashReporter SDK.
 */
+ (dispatch_queue_t)sharedQueue;

@end

NS_ASSUME_NONNULL_END
