#import "RCRRequestHandler.h"
#import "RCRDeviceInformation.h"
#import "RCRSessionBuilder.h"
#import "RCRConstants.h"
#import "RCRRequestUtil.h"

// Request constants.
static NSString* const HTTP_METHOD = @"POST";
static NSString* const HTTP_CONTENT_TYPE = @"application/json";

// Schema key constants.
static NSString* const PLATFORM = @"platform"; // Platform of the device. E.G iOS.
static NSString* const APP_ID = @"app_id"; // Bundle ID of the application.
static NSString* const VERSION = @"version"; // Current build version.
static NSString* const DEVICE_ID = @"device_id"; // Replaced with vendor ID since UUID is not available.
static NSString* const LOCALE = @"locale"; // Locale of device. E.G en_US.
static NSString* const DEVICE_INFO = @"device_info"; // Device info object to nest other fields.
static NSString* const CARRIER = @"carrier"; // Carrier of the device. Returns NULL if device has no carrier.
static NSString* const MAKE = @"make";  // Make of phone. E.G "iPhone", "iPad".
static NSString* const MODEL = @"model"; // Model of device. Apple device identifier will be sent to the server. E.G "iPhone4,1".
static NSString* const OS = @"os"; // Operating system of device. E.G "iOS".
static NSString* const OS_VERSION = @"os_version"; // Operating system version of device. E.G "10.3.1".
static NSString* const PROCESSOR = @"processor";
static NSString* const CPU = @"CPU";
static NSString* const MEMORY = @"memory"; // Total physical memory in bytes.
static NSString* const STATUS = @"status"; // Status of device when ran.
static NSString* const LIFECYCLES = @"lifecycles"; // Status of device when ran.

@implementation RCRRequestHandler

+ (void)sendInstallEvent:(NSString*)status
{
    NSString* statusToPost = status ? : @"";
    NSDictionary *dictionaryToSend = @{
                                       APP_ID:       [RCRDeviceInformation getDeviceAppId],
                                       LOCALE:       [RCRDeviceInformation getDeviceLocale],
                                       CARRIER:      [RCRDeviceInformation getDeviceCarrier],
                                       DEVICE_ID:    [RCRDeviceInformation getDeviceId],
                                       VERSION:      [RCRRequestUtil getAppVersionAndBuild],
                                       STATUS:       statusToPost,
                                       DEVICE_INFO:  @{
                                                       MAKE:         [RCRDeviceInformation getDeviceMake],
                                                       MODEL:        [RCRDeviceInformation getDeviceModel],
                                                       OS:           [RCRDeviceInformation getDeviceOS],
                                                       OS_VERSION:   [RCRDeviceInformation getDeviceOSVersion],
                                                       MEMORY:       [RCRDeviceInformation getDeviceMemory]
                                                       }
                                       };

    [self sendDictionary:dictionaryToSend endPoint:[RCRConstants sharedInstance].installURL completionHandler:^{
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:true forKey:INSTALL_EVENT_SENT];
    }];
}

+ (void)sendSessionEvent:(NSMutableArray <NSDictionary *> *)sessionToSend
{
    NSDictionary *dictionaryToSend = @{
                                       PLATFORM:    [RCRDeviceInformation getDeviceOS],
                                       APP_ID:      [RCRDeviceInformation getDeviceAppId],
                                       VERSION:     [RCRRequestUtil getAppVersionAndBuild],
                                       DEVICE_ID:   [RCRDeviceInformation getDeviceId],
                                       LIFECYCLES:  sessionToSend
                                       };

    [self sendDictionary:dictionaryToSend endPoint:[RCRConstants sharedInstance].sessionURL completionHandler:^{
        [RCRSessionBuilder clearPListSessionList];
    }];
}

+ (void)sendDictionary:(NSDictionary *)dictionary
              endPoint:(NSString *)endPoint
     completionHandler:(void (^)(void))completionHandler {
    // Create request body to send.
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:0];

    NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]]; // Length of body.
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];

    [request setURL:[NSURL URLWithString:endPoint]]; // Endpoint of request.
    [request setHTTPMethod:HTTP_METHOD]; // HTTP method to use.
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:HTTP_CONTENT_TYPE forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData]; // Setting body of request.

    NSURLSessionConfiguration *sessionConfig = [RCRRequestUtil getSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];

    // Send out response.
    [[session dataTaskWithRequest:request
                completionHandler:^(
                                    NSData * _Nullable data,
                                    NSURLResponse * _Nullable response,
                                    NSError * _Nullable error
                                    )
      {
          // If response is OK, check the status code.
          if (response)
          {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
              if ([httpResponse statusCode] == 200)
              {
                  completionHandler();
              }
          }
      }] resume];
}

+ (NSString*)parseOriginError:(NSMutableArray <NSDictionary *> *)sessionToSend
{
    return [[sessionToSend valueForKeyPath:@"crash_details.origin_error"] componentsJoinedByString:@""];
}

@end
