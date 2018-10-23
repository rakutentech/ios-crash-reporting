#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Constants.h
 * Class is used to hold all constants variable that reflects the whole codebase.
 */
FOUNDATION_EXPORT NSString* const INSTALL_EVENT_SENT;
FOUNDATION_EXPORT NSString* const LIFECYCLE_KEY;
FOUNDATION_EXPORT NSString* const CUSTOM_KEY;
FOUNDATION_EXPORT NSString* const CUSTOM_LOG;

@interface RCRConstants : NSObject
{
    NSString* _installURL;
    NSString* _sessionURL;
    NSNumber* _prevIsEnabled;
    BOOL _isConfigFlagSet;
}

+ (RCRConstants *)sharedInstance;

@property(strong, nonatomic, readwrite) NSString* installURL;
@property(strong, nonatomic, readwrite) NSString* sessionURL;
@property(strong, nonatomic, readwrite) NSNumber* prevIsEnabled;
@property (nonatomic, assign) BOOL isConfigFlagSet; // True if talking to config server the first time fails.

@end

NS_ASSUME_NONNULL_END
