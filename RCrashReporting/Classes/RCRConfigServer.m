#import "RCRConfigServer.h"
#import "RCRConstants.h"
#import "RCRDeviceInformation.h"
#import "RCRRequestUtil.h"

// Current SDK Version.
static NSString* const CURRENT_SDK_VERSION = @"0.4.0"; // Change this every release!

// Request body variables for configuration server.
static NSString* const PLATFORM = @"platform";
static NSString* const APP_ID = @"app_id";
static NSString* const APP_VERSION = @"app_version";
static NSString* const DEVICE_ID = @"device_id";
static NSString* const SDK_VERSION = @"sdk_version";

static NSString* const ENABLED = @"enabled";
static NSString* const STICKY = @"sticky";

@implementation RCRConfigServer

+ (BOOL)checkEnable:(NSNumber*)enabled
     responseSticky:(NSNumber*)sticky
   responseOverride:(NSNumber*)responseOverride
{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    RCRConstants* constants = [RCRConstants sharedInstance];

    if ([responseOverride boolValue])
    {
        if([sticky boolValue])
        {
            [defaults setObject:enabled forKey:ENABLED];
        }
        else
        {
            [defaults removeObjectForKey:ENABLED];
        }
        return ([enabled boolValue]);
    }
    else
    {
        if (!constants.prevIsEnabled)
        {
            if ([sticky boolValue])
            {
                [defaults setObject:enabled forKey:ENABLED];
            }
            return ([enabled boolValue]);
        }
        else
        {
            return ([constants.prevIsEnabled boolValue]);
        }
    }
}

+ (void)setPreviousEnable
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    RCRConstants* constants = [RCRConstants sharedInstance];
    constants.prevIsEnabled = [defaults objectForKey:ENABLED];
}

+ (BOOL)checkConfigServer
{
    RCRConstants* constants = [RCRConstants sharedInstance];
    
    // Set previous 'enabled' values.
    [RCRConfigServer setPreviousEnable];
    
    // Response variables
    __block NSNumber* enabled;
    __block NSNumber* sticky;
    __block NSNumber* override;
    
    NSBundle *bundle = NSBundle.mainBundle;
    
    NSURL *base = [NSURL URLWithString:(NSString *)[bundle objectForInfoDictionaryKey:@"RCRConfigAPIEndpoint"]];
#if DEBUG
    NSAssert(base, @"Your application's Info.plist must contain a key 'RCRConfigAPIEndpoint' set to the endpoint URL of your Crash Config API");
#endif
    
    NSString *relayAppID = [bundle objectForInfoDictionaryKey:@"RPTRelayAppID"];
#if DEBUG
    NSAssert(relayAppID.length, @"Your application's Info.plist must contain a key 'RPTRelayAppID' set to the application ID for your Mission Control app");
#endif
    
    NSString *path = [NSString stringWithFormat:@"config/configuration/%@", relayAppID];
    NSURL *url = [base URLByAppendingPathComponent:path];
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.query = [NSString stringWithFormat:@"sdk_version=%@&app_version=%@", RCRSDKVersion, [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSURL *configURL = components.URL;
    
    // Semaphore to wait for config server response before continuing SDK code.
    // This will not hang the application because it is done asynch.
    dispatch_semaphore_t sem;
    sem = dispatch_semaphore_create(0);
    
    NSURLSessionConfiguration *sessionConfig = [RCRRequestUtil getSessionConfiguration];
    sessionConfig.timeoutIntervalForResource = 5.0;

    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[session dataTaskWithURL:configURL
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error)
                    {
                        NSLog(@"Error: %@", error);
                        constants.isConfigFlagSet = true;
                    }
                                         
                    if (response)
                    {
                        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                        if ([httpResponse statusCode] == 200)
                        {
                            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                   error:&error];
                             
                            constants.installURL = [json valueForKeyPath:@"data.endpoints.install"];
                            constants.sessionURL = [json valueForKeyPath:@"data.endpoints.session"];
                            
                            enabled = [json valueForKeyPath:@"data.enabled"];
                            sticky = [json valueForKeyPath:@"data.sticky"];
                            override = [json valueForKeyPath:@"data.override"];
                            constants.isConfigFlagSet = false;
                        }
                        else
                        {
                            constants.isConfigFlagSet = true;
                        }
                    } 
                    else
                    {
                        constants.isConfigFlagSet = true;
                    }
                    dispatch_semaphore_signal(sem);
                }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return [RCRConfigServer checkEnable:enabled responseSticky:sticky responseOverride:override];
}

@end
