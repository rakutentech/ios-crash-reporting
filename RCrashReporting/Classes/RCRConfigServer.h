#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * ConfigServer.h
 * Class is used to parse configuration server's response and based on the response,
 * it will enable or disable the whole SDK. Install event and session event URL are
 * also captured here for use if an install/session has to be sent. The class also accesses
 * NSUserDefaults to write a 'sticky' variable to be saved for next time it talks to the 
 * configuration server.
 */
@interface RCRConfigServer : NSObject

/**
 * Returns boolean of if the SDK should be enabled or disabled based on
 * configuration server's response.
 */
+ (BOOL)checkEnable:(NSNumber*)enabled
     responseSticky:(NSNumber*)sticky
   responseOverride:(NSNumber*)responseOverride;

/**
 * Records previous enabled value (sticky) to a variable.
 */
+ (void)setPreviousEnable;

/**
 * Return boolean of the 'enabled' key from config server.
 * Sets the constants provided by the config server if 'enabled' is true.
 */
+ (BOOL)checkConfigServer;

@end

NS_ASSUME_NONNULL_END
