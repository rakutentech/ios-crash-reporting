#import "RCRConstants.h"

@implementation RCRConstants
@synthesize installURL = _installURL;
@synthesize sessionURL = _sessionURL;
@synthesize prevIsEnabled = _prevIsEnabled;
@synthesize isConfigFlagSet = _isConfigFlagSet;

// Key for plist file to check first boot of app.
NSString* const INSTALL_EVENT_SENT = @"RAFirstBootUpInstallEventSent";

// Key for plist file to store all life cycles and crash events.
NSString* const LIFECYCLE_KEY = @"RALifecycleList";

// Key for plist file to store all custom key-value pairs.
NSString* const CUSTOM_KEY = @"RACustom_keys";

// Key for plist file to store all custom logs.
NSString* const CUSTOM_LOG = @"RACustom_logs";

+ (RCRConstants *)sharedInstance {
    static dispatch_once_t onceToken;
    static RCRConstants *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[RCRConstants alloc] initSharedInstance];
    });
    return instance;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (instancetype)initSharedInstance {
    self = [super init];
    if (self) {
        _installURL = nil;
        _sessionURL = nil;
        _prevIsEnabled = nil;
        _isConfigFlagSet = false;
    }
    return self;
}

@end
