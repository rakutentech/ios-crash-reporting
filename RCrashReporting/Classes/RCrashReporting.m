#import "RCrashReporting.h"
#import "RCRRequestHandler.h"
#import "RCRSessionBuilder.h"
#import "RCRConstants.h"
#import "RCRConfigServer.h"
#import "RCRRequestUtil.h"
#import "KSCrash.h"
#import "RCRReachability.h"

// Status constants.
static NSString* const ACTIVE_STATUS = @"ACTIVE";
static NSString* const INACTIVE_STATUS = @"INACTIVE";
static NSString* const UPGRADED_STATUS = @"UPGRADED";
static NSString* const UNINSTALLED_STATUS = @"UNINSTALLED";

// Serial queue used to enqueue tasks.
dispatch_queue_t sharedQueue;

// Initialize instance for Reachability API.
RCRReachability* reach;

@implementation RCrashReporting

+ (void)load
{
    // Create dispatch queue for asych tasks.
    sharedQueue = [RCrashReporting sharedQueue];
    
    // Listener for network changes.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    [[[RCrashReporting alloc] init] setUpReachability];
    
    dispatch_async(sharedQueue, ^{
        @try
        {
            [self initializeCrashReporting];
        }
        @catch (NSException* exception)
        {
            [RCRRequestUtil printTroubleshootHelp:exception];
        }
    });
}

+ (void)initializeCrashReporting
{
    if ([RCRConfigServer checkConfigServer]){
        
#ifdef DEBUG
        NSLog(@"Valid config received. Now initialize crash handler and reporting.");
#endif
        
        // Install KSCrash handler to record crashes.
        KSCrash* handler = [KSCrash sharedInstance];
        [handler install];

        // Setup variables needed.
        [RCRSessionBuilder setUpSession];
        
        // Check if install event sent yet.
        if ([self isFirstInstallEventSent])
        {
            dispatch_async(sharedQueue, ^{
                @try
                {
                    [RCRRequestHandler sendInstallEvent:ACTIVE_STATUS];
                }
                @catch (NSException* exception)
                {
                    [RCRRequestUtil printTroubleshootHelp:exception];
                }
            });
        }
        
        // Start first session tracking when app is loaded.
        dispatch_async(sharedQueue, ^{
            @try
            {
                [RCRSessionBuilder enterForeground];
            }
            @catch (NSException* exception)
            {
                [RCRRequestUtil printTroubleshootHelp:exception];
            }
        });
        
        // Create listeners for state change events.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate)
                                                     name:UIApplicationWillTerminateNotification object:nil];
    }
}

// Invoked when application goes to foreground.
+ (void)appDidBecomeActive
{
    dispatch_async(sharedQueue, ^{
        @try
        {
            [RCRSessionBuilder enterForeground]; // Saves timestamp when going into foreground.
        }
        @catch (NSException* exception)
        {
            [RCRRequestUtil printTroubleshootHelp:exception];
        }
    });
}

// Invoked when application goes to background.
+ (void)appWillResignActive
{
    dispatch_async(sharedQueue, ^{
        @try
        {
            [RCRSessionBuilder enterBackground]; // Saves timestamp when going into background.
        }
        @catch (NSException* exception)
        {
            [RCRRequestUtil printTroubleshootHelp:exception];
        }
    });
}

// Invoked when application is terminated.
+ (void)appWillTerminate
{
    NSLog(@"Terminated");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

+ (BOOL)isFirstInstallEventSent
{
    // Return true if install event is sucessfully sent.
    return ![[NSUserDefaults standardUserDefaults] objectForKey:INSTALL_EVENT_SENT];
}

+ (dispatch_queue_t)sharedQueue
{
    static dispatch_queue_t sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create("Crash Reporting Queue", DISPATCH_QUEUE_SERIAL);
    });
    return sharedQueue;
}

/**
 * Invoked when network status changes.
 * Retry talking to configuration server if unsuccessful befo
 */
+ (void)reachabilityChanged:(NSNotification*)notice
{
    RCRConstants* constants = [RCRConstants sharedInstance];
    NetworkStatus remoteHostStatus = [reach currentReachabilityStatus];
    
    if ((constants.isConfigFlagSet) && (remoteHostStatus != NotReachable))
    {
        [self initializeCrashReporting];
    }
}

/**
 * Start listener for Reachbility  API.
 */
- (void)setUpReachability
{
    reach = [RCRReachability reachabilityForInternetConnection];
    [reach startNotifier];
}

@end
