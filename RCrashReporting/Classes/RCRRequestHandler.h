#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * RequestHandler.h
 * Class is used to handle any HTTP(S) request made by the program.
 */
@interface RCRRequestHandler : NSObject

/**
 * Crash Reporting install event.
 * Reports install event to Crash Report Server.
 */
+ (void)sendInstallEvent:(NSString*)status;

/**
 * Crash Reporting persisting start/end/crash event.
 * Params sessionToSend is crash_details to send.
 */
+ (void)sendSessionEvent:(NSMutableArray <NSDictionary *> *)sessionToSend;

/**
 * Returns string origin_error.
 * Parse out origin_error from crash_details as a string.
 */
+ (NSString*)parseOriginError:(NSMutableArray <NSDictionary *> *)sessionToSend;

@end

NS_ASSUME_NONNULL_END
