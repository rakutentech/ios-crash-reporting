#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/sysctl.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * DeviceInformation.h
 * Class is used as a helper class for retrieiving device information.
 */
@interface RCRDeviceInformation : NSObject

/**
 * Returns current build version.
 */
+ (NSString*)getDeviceVersion;

/**
 * Returns bundle ID of the application.
 */
+ (NSString*)getDeviceAppId;

/**
 * Returns locale of device. E.G en_US.
 */
+ (NSString*)getDeviceLocale;

/**
 * Returns operating system of device. E.G "iOS".
 */
+ (NSString*)getDeviceOS;

/**
 * Returns operating system version of device. E.G "10.3.1".
 */
+ (NSString*)getDeviceOSVersion;

/**
 * Returns make of phone. E.G "iPhone", "iPad".
 */
+ (NSString*)getDeviceMake;

/**
 * Returns vendor ID since UUID is not available.
 */
+ (NSString*)getDeviceId;

/**
 * Returns device carrier name. E.G "T-Mobile".
 */
+ (NSString*)getDeviceCarrier;

/**
 * Returns total memory of device in bytes.
 */
+ (NSString*)getDeviceMemory;

/**
 * Returns apple device's identifier. E.G "iPhone4,1".
 */
+ (NSString*)getDeviceModel;

/**
 * Returns application version number. E.G "1.2".
 */
+ (NSString*)getAppVersion;

/**
 * Returns application build number. E.G "23".
 */
+ (NSString*)getBuildNumber;

/**
 * Returns free storage space in bytes. E.G "32424124"
 */
+ (NSString*)getFreeDiskspace;

@end

NS_ASSUME_NONNULL_END
