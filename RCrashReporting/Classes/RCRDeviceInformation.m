#import "RCRDeviceInformation.h"

@implementation RCRDeviceInformation

+ (NSString*)getDeviceVersion
{
    NSString* deviceCurrentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ? : @"";
    return deviceCurrentVersion;
}

+ (NSString*)getAppVersion
{
    NSString* deviceAppVersion = [NSString stringWithFormat:@"%@",
                                  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    return deviceAppVersion;
}

+ (NSString*)getDeviceAppId
{
    NSString* deviceAppId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] ? : @"";
    return deviceAppId;
}

+ (NSString*)getDeviceLocale
{
    NSString* deviceLocale = [[NSLocale preferredLanguages] objectAtIndex:0] ? : @"";
    return deviceLocale;
}

+ (NSString*)getDeviceOS
{
    NSString* deviceOS = [UIDevice currentDevice].systemName ? : @"";
    return deviceOS;
}

+ (NSString*)getDeviceOSVersion
{
    NSString* deviceOSVersion = [UIDevice currentDevice].systemVersion ? : @"";
    return deviceOSVersion;
}

+ (NSString*)getDeviceMake
{
    NSString* deviceMake = [UIDevice currentDevice].model ? : @"";
    return deviceMake;
}

+ (NSString*)getDeviceId
{
    NSUUID* identierForVendor = [UIDevice currentDevice].identifierForVendor;
    NSString* deviceId = [identierForVendor UUIDString] ? : @"";
    return deviceId;
}

+ (NSString*)getDeviceCarrier
{
    CTTelephonyNetworkInfo* networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* carrier = networkInfo.subscriberCellularProvider;
    NSString* deviceCarrier = carrier.carrierName ? : @""; // Carrier name. Null if none.
    return deviceCarrier;
}

+ (NSString*)getDeviceMemory
{
    NSProcessInfo* pinfo = [NSProcessInfo processInfo];
    NSString* deviceMemory = [NSString stringWithFormat:@"%lld", [pinfo physicalMemory]] ? : @""; // Total RAM.
    return deviceMemory;
}

+ (NSString*)getDeviceModel
{
    char* name = "hw.machine";
    size_t size;
    sysctlbyname(name, NULL, &size, NULL, 0);
    char* machine = malloc(size);
    sysctlbyname(name, machine, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding] ? : @"";
    free(machine);
    return deviceModel;
}

+ (NSString*)getBuildNumber
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString*)getFreeDiskspace
{
    NSDictionary *atDict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error:NULL];
    long freeSpace = [[atDict objectForKey:NSFileSystemFreeSize] longValue];
    return [NSString stringWithFormat:@"%ld", freeSpace];
}

@end
