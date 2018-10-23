#import "RCRSessionBuilder.h"
#import "RCRRequestHandler.h"
#import "RCrashReporting.h"
#import "RCRConstants.h"
#import "RCRRequestUtil.h"
#import "KSCrash.h"
#import "RCRKSCrashHelper.h"
#import "RCRDeviceInformation.h"

// Request body constants.
static NSString* const CRASH_DETAILS = @"crash_details";
static NSString* const ORIGIN_ERROR = @"origin_error";
static NSString* const STACK_TRACE = @"stack_trace";
static NSString* const SYSTEM_STATS = @"system_stats";
static NSString* const THREADS = @"threads";
static NSString* const FOREGROUND = @"fg";
static NSString* const BACKGROUND = @"bg";
static NSString* const SYS_KEY = @"sys_key";
static NSString* const SYS_VALUE = @"sys_value";
static NSString* const APP_EVENTS = @"app_events";
static NSString* const APP_KEY = @"app_key";
static NSString* const APP_VALUE = @"app_value";
static NSString* const LOG = @"log";
static NSString* const OS_VERSION = @"os_version";
static NSString* const DEVICE_MODEL = @"device_model";
static NSString* const FREE_DISK_SPACE = @"free_disk_space";
static NSString* const TOTAL_DISK_SPACE = @"total_disk_space";
static NSString* const FREE_RAM = @"free_ram";
static NSString* const TOTAL_RAM = @"total_ram";
static NSString* const IS_APP_IN_FOCUS = @"is_app_in_focus";
static NSString* const CPU_ARCH = @"cpu_arch";

// Lifecycle variables.
static long long const MAX_FILE_BYTES = 500000; // PList file size in bytes. Flush to server if file size exceeds this number.

// Lifecycle array and foreground/background variables.
NSMutableArray* lifecycleArray;
long foregroundTimestamp;
long backgroundTimestamp;

// Save foreground timestamp now that KSCrash is taking control after a crash.
// Background timestamp will be provided by KSCrash.
static NSString* const FOREGROUND_TIMESTAMP = @"fg_timestamp";

@implementation RCRSessionBuilder

+ (void)setUpSession
{
    lifecycleArray = [[[NSUserDefaults standardUserDefaults] objectForKey:LIFECYCLE_KEY] mutableCopy] ? : [NSMutableArray array];
    
    NSArray* crashReports = [RCRKSCrashHelper getArrayOfCrashReports];
    if ([crashReports count])
    {
        for (id report in crashReports)
        {
            if (![self isLocalFileTooBig])
            {
                [self parseAndAppendEachCrashReport:report];
            }
        }
        KSCrash* handler = [KSCrash sharedInstance];
        [handler deleteAllReports];
    }

    dispatch_queue_t sharedQueue = [RCrashReporting sharedQueue];
    dispatch_async(sharedQueue, ^{
        @try
        {
            [RCRRequestHandler sendSessionEvent:lifecycleArray];
        }
        @catch (NSException* exception)
        {
            [RCRRequestUtil printTroubleshootHelp:exception];
        }
    });
    
}

+ (void)appendLifecycleTimestamps
{
    [self verifyAndFixFgTimestampsIfNeeded];
    
    NSDictionary* session = @{
                              FOREGROUND : [NSNumber numberWithLong:foregroundTimestamp],
                              BACKGROUND : [NSNumber numberWithLong:backgroundTimestamp]
                              };
    
    [lifecycleArray addObject:session];
    [[NSUserDefaults standardUserDefaults] setObject:lifecycleArray forKey:LIFECYCLE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Clear timestamp variable after writing to plist file.
    foregroundTimestamp = 0;
    backgroundTimestamp = 0;
}

/**
 * Function called by 'UIApplicationWillEnterForegroundNotification' observer.
 * Invoked when application goes into foreground.
 */
+ (void)enterForeground
{
    foregroundTimestamp = [self getCurrentTime];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* convertedFgTimestamp = [[NSNumber alloc] initWithLong:foregroundTimestamp];
    [defaults setObject:convertedFgTimestamp forKey:FOREGROUND_TIMESTAMP];
    [defaults synchronize];
}

/**
 * Function called by 'UIApplicationWillResignActiveNotification' observer.
 * Invoked when application goes into background.
 */
+ (void)enterBackground
{
    backgroundTimestamp = [self getCurrentTime];
    [self appendLifecycleTimestamps];
    
    if ([self isLocalFileTooBig])
    {
        [RCRRequestHandler sendSessionEvent:lifecycleArray];
        NSLog(@"Local file size exceeded %lld bytes.", MAX_FILE_BYTES);
    }
}

+ (long)getCurrentTime
{
    double timestamp = [[NSDate date] timeIntervalSince1970];
    return (long)timestamp;
}

+ (void)clearPListSessionList
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LIFECYCLE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    lifecycleArray = [NSMutableArray array];
}

+ (BOOL)isLocalFileTooBig
{
    NSString* libraryDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [libraryDir stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"/Preferences/%@.plist",[[NSBundle mainBundle] bundleIdentifier]]];
    
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil][NSFileSize] longLongValue];
    
    return fileSize > MAX_FILE_BYTES ? true : false;
}

/**
 * Returns array of multiple dictionaries with each dictionary including
 * two keys 'app_key' and 'app_value'. Each dictionary is set by the developers
 * using CustomDefault's writeCustomKeyValue method.
 */
+ (NSMutableArray <NSDictionary *> *)getCustomKeysArray
{
    NSMutableArray* customKeyArray = [[NSMutableArray alloc] init];
    NSMutableDictionary* customKeyDict = [[[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_KEY] mutableCopy];
    
    if ([customKeyDict count])
    {
        for (id key in customKeyDict)
        {
            NSDictionary* tempDict = @{
                                       APP_KEY  : key,
                                       APP_VALUE: [customKeyDict objectForKey:key]
                                       };
            [customKeyArray addObject:tempDict];
        }
    }
    
    // Append custom log into the array.
    [customKeyArray addObject:@{
                                APP_KEY  : LOG,
                                APP_VALUE: [self getCustomLogs]
                                }];
    
    return customKeyArray;
}

/**
 * Returns the value of last background timestamp recorded by parsing through NSUserDefaults.
 */
+ (NSNumber*)getOldestBackground
{
    NSMutableArray* lifecycleArr = [[NSUserDefaults standardUserDefaults] objectForKey:LIFECYCLE_KEY];
    if (lifecycleArr)
    {
        NSMutableArray* lastSession = [lifecycleArr lastObject];
        return [lastSession valueForKey:BACKGROUND];
    }
    
    return [NSNumber numberWithLong:[self getCurrentTime]];
}

/**
 * Used to verify foreground timestamps are recorded properly before storing.
 * In the case of foreground being 0, it will calculate the approximate foreground by
 * grabbing the last background timestamp, adding it with the current background
 * timestamp, and then dividing that sum by two.
 * Method is made to resolve an issue where UIApplicationWillEnterForegroundNotification
 * is not called when the application is entered and exited
 * too quickly within a span of milliseconds.
 */
+ (void)verifyAndFixFgTimestampsIfNeeded
{
    if (foregroundTimestamp == 0)
    {
        foregroundTimestamp = (([[self getOldestBackground] integerValue] + backgroundTimestamp) / 2);
    }
}

/**
 * Returns string of all individual logs concatenated. Each log
 * message is delimited by a new line with the most recent log
 * at the bottom/end of the string.
 */
+ (NSMutableString*)getCustomLogs
{
    NSMutableString* concatenatedLogs = [[NSMutableString alloc] init];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* customLogsArr = [[defaults objectForKey:CUSTOM_LOG] mutableCopy];
    
    if ([customLogsArr count])
    {
        for (id ele in customLogsArr)
        {
            [concatenatedLogs appendString:[NSString stringWithFormat:@"%@\r\n", ele]];
        }
    }
    return concatenatedLogs;
}

/**
 * Returns dictionary containing key/value pair for 'system_stats' field.
 */
+ (NSMutableDictionary*)addToSystemStats:(NSString*)key forValue:(NSMutableDictionary*)value
{
    NSMutableDictionary* systemStatsDict = [[NSMutableDictionary alloc] init];
    [systemStatsDict setObject:key forKey:SYS_KEY];
    [systemStatsDict setObject:value forKey:SYS_VALUE];
    return systemStatsDict;
}

/**
 * Method to parse each crash report generated by KSCrash for fields that we want --
 * including total memory, usable memory, disk space, origin error, stack trace, and timestamp.
 * Method will build a dictionary object with those fields and write them to NSUserDefaults.
 * All crash reports will be deleted when it gets builds into dictionary object which will be
 * sent to the backend server as the response body.
 */
+ (void)parseAndAppendEachCrashReport:(NSMutableDictionary*)crashReport
{
    // Parse out device model.
    NSString* deviceModel = [crashReport valueForKeyPath:@"system.machine"] ? : @"";
    
    // Parse out OS version.
    NSString* osVersion = [crashReport valueForKeyPath:@"system.system_version"] ? : @"";
    
    // Parse out memory in bytes.
    NSString* freeMemory = [NSString stringWithFormat:@"%@", [crashReport valueForKeyPath:@"system.memory.free"]] ? : @"";
    NSString* totalMemory = [NSString stringWithFormat:@"%@", [crashReport valueForKeyPath:@"system.memory.size"]] ? : @"";

    // Parse out timestamp of when the crash happened.
    NSString* bgTimestamp = [crashReport valueForKeyPath:@"report.timestamp"] ? : @"";
    
    // Parse out total disk space.
    NSString* totalDiskSpace = [NSString stringWithFormat:@"%@", [crashReport valueForKeyPath:@"system.storage"]] ? : @"";
    
    // Parse out application is in foreground.
    NSNumber* appIsFocus = [crashReport valueForKeyPath:@"system.application_stats.application_in_foreground"];
    NSString* convertedAppIsFocus = @"";
    if (appIsFocus) {
        convertedAppIsFocus = [appIsFocus boolValue] ? @"true" : @"false";
    }
    
    // Parse out cpu architecture of device.
    NSString* cpuArch = [crashReport valueForKeyPath:@"system.cpu_arch"] ? : @"";

    // Parse out origin_error. 'nsexception' field only shows when a NSException occurs and if it
    // is not a NSException, it will grab the signal name.
    NSString* origin_error =
        [crashReport valueForKeyPath:@"crash.error.nsexception.name"] ? :
            [crashReport valueForKeyPath:@"crash.error.signal.name"];
    
    // Parse out first line of stack trace.
    NSString* stackTrace = [[crashReport valueForKeyPath:@"crash.threads"][0] valueForKeyPath:@"backtrace.contents"][0] ? : @"";
    NSString* symbolName = [stackTrace valueForKey:@"symbol_name"] ? : @"";
    NSString* symbolAddr = [stackTrace valueForKey:@"symbol_addr"] ? : @"";
    NSString* instrAddr = [stackTrace valueForKey:@"instruction_addr"] ? : @"";
    
    uintptr_t offset = (uintptr_t)instrAddr - (uintptr_t)symbolAddr;
    
    NSString* firstLineOfStacktrace = [NSString stringWithFormat:@"%d\t%-30@  0x%08" PRIxPTR " 0x%lx + %lu\n",
                                       0, symbolName, (uintptr_t)instrAddr, (uintptr_t)symbolAddr, offset] ? : @"";

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber* fgTimestamp = [defaults objectForKey:FOREGROUND_TIMESTAMP];
    
    // Stringify JSON crash report.
    NSString* stringifyCrashReport;
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:crashReport
                                                       options:0
                                                         error:&error];
    
    stringifyCrashReport = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ? : @"";
    
    NSDictionary* crashDetails = @{
                                    FOREGROUND : fgTimestamp,
                                    BACKGROUND : bgTimestamp,
                                    CRASH_DETAILS: @{
                                                    STACK_TRACE : firstLineOfStacktrace,
                                                    ORIGIN_ERROR: origin_error,
                                                    APP_EVENTS  : [self getCustomKeysArray],
                                                    SYSTEM_STATS: @[
                                                                    @{
                                                                        SYS_KEY: @"ks_crash_report",
                                                                        SYS_VALUE: stringifyCrashReport
                                                                        },
                                                                    @{
                                                                        SYS_KEY: OS_VERSION,
                                                                        SYS_VALUE: osVersion
                                                                        },
                                                                    @{
                                                                        SYS_KEY: DEVICE_MODEL,
                                                                        SYS_VALUE: deviceModel
                                                                        },
                                                                    @{
                                                                        SYS_KEY: FREE_DISK_SPACE,
                                                                        SYS_VALUE: [RCRDeviceInformation getFreeDiskspace]
                                                                        },
                                                                    @{
                                                                        SYS_KEY: FREE_RAM,
                                                                        SYS_VALUE: freeMemory
                                                                        },
                                                                    @{
                                                                        SYS_KEY: IS_APP_IN_FOCUS,
                                                                        SYS_VALUE: convertedAppIsFocus
                                                                        },
                                                                    @{
                                                                        SYS_KEY: TOTAL_RAM,
                                                                        SYS_VALUE: totalMemory
                                                                        },
                                                                    @{
                                                                        SYS_KEY: TOTAL_DISK_SPACE,
                                                                        SYS_VALUE: totalDiskSpace
                                                                    },
                                                                    @{
                                                                        SYS_KEY: CPU_ARCH,
                                                                        SYS_VALUE: cpuArch
                                                                    }
                                                                    ]
                                                    }
                                    };
    
    [lifecycleArray addObject:crashDetails];
    [defaults setObject:lifecycleArray forKey:LIFECYCLE_KEY];
    [defaults synchronize];
}

@end
