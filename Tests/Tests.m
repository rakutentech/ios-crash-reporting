#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <RCrashReporting/RCrashReporting.h>
#import <RCrashReporting/RCRSessionBuilder.h>
#import <RCrashReporting/RCRDeviceInformation.h>
#import <RCrashReporting/RCRRequestHandler.h>
#import <RCrashReporting/RCRConstants.h>
#import <RCrashReporting/RCRConfigServer.h>
#import <RCrashReporting/RCRCustomDefault.h>

@interface CRDemoProject : XCTestCase

@end

id mockSessionBuilder;
id mockUserDefaults;
id mockRequestHandler;
id mockArray;
id mockNSMutableURLRequest;
id mockNSURL;
id mockNSURLSession;
id mockNSNoticationCenter;
id mockRequestHandler;
id mockNSURLSessionConfiguration;
id mockConstants;
id defaults;
RCRConstants* constants;
NSString* keyForTesting = @"testKey";

@implementation CRDemoProject

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [defaults removeObjectForKey:keyForTesting];
    [defaults removeObjectForKey:CUSTOM_KEY];
    [defaults removeObjectForKey:CUSTOM_LOG];
    mockSessionBuilder = OCMClassMock([RCRSessionBuilder class]);
    mockRequestHandler = OCMClassMock([RCRRequestHandler class]);
    mockConstants = OCMClassMock([RCRConstants class]);
    mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    mockNSMutableURLRequest = OCMClassMock([NSMutableURLRequest class]);
    mockNSURL = OCMClassMock([NSURL class]);
    mockNSURLSession = OCMClassMock([NSURLSession class]);
    mockArray = OCMClassMock([NSMutableArray class]);
    mockNSNoticationCenter = OCMClassMock([NSNotificationCenter class]);
    mockNSURLSessionConfiguration = OCMClassMock([NSURLSessionConfiguration class]);
    defaults = [NSUserDefaults standardUserDefaults];
    constants = [RCRConstants sharedInstance];
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    RCRConstants* constants = [RCRConstants sharedInstance];
    constants.prevIsEnabled = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"enabled"];
    [defaults removeObjectForKey:keyForTesting];
    [defaults removeObjectForKey:CUSTOM_KEY];
    [defaults removeObjectForKey:CUSTOM_LOG];
    [super tearDown];
}

/**
 * SessionBuilder class tests.
 */
- (void)testForegroundActive
{
    [[mockSessionBuilder expect] getCurrentTime];
    [RCRSessionBuilder enterBackground];
    [mockSessionBuilder verify];
}

- (void)testBackgroundActive
{
    [[mockSessionBuilder expect] getCurrentTime];
    [[mockSessionBuilder expect] appendLifecycleTimestamps];
    [RCRSessionBuilder enterBackground];
    [mockSessionBuilder verify];
}

- (void)testAppendLifeCycleTimestamps
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMStub([mockUserDefaults setObject:[OCMArg any] forKey:[OCMArg any]]);
    OCMStub([mockArray addObject:[OCMArg any]]).andReturn(mockArray);
    [RCRSessionBuilder appendLifecycleTimestamps];
    OCMVerify([mockUserDefaults standardUserDefaults]);
    OCMVerify([array addObject:[OCMArg any]]);
    OCMVerify([mockUserDefaults setObject:[OCMArg any] forKey:[OCMArg any]]);
}

- (void)testGetCurrentTime
{
    long currentTime = [RCRSessionBuilder getCurrentTime];
    
    XCTAssert(currentTime > 0);
}

/**
 * Device Information class tests.
 */
- (void)testGetDeviceVersion
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceVersion]);
}

- (void)testGetDeviceAppId
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceId]);
}

- (void)testGetDeviceLocale
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceLocale]);
}

- (void)testGetDeviceOS
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceOS]);
}

- (void)testGetDeviceOSVersion
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceOSVersion]);
}

- (void)testGetDeviceMake
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceMake]);
}

- (void)testGetDeviceId
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceId]);
}

- (void)testGetDeviceCarrier
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceCarrier]);
}

- (void)testGetDeviceMemory
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceMemory]);
}

- (void)testGetDeviceModel
{
    XCTAssertNotNil([RCRDeviceInformation getDeviceModel]);
}

/**
 * CrashReporting class tests.
 */
- (void)testAppDidBecomeActive
{
    OCMStub([mockSessionBuilder enterForeground]);
    [RCRSessionBuilder enterForeground];
    [NSThread sleepForTimeInterval:.5];
    OCMVerify([mockSessionBuilder enterForeground]);
}

- (void)testAppWillResignActive
{
    OCMStub([mockSessionBuilder enterBackground]);
    [RCRSessionBuilder enterBackground];
    [NSThread sleepForTimeInterval:.5];
    OCMVerify([mockSessionBuilder enterBackground]);
}

- (void)testAppWillTerminate
{
    OCMStub([mockNSNoticationCenter defaultCenter]).andReturn(mockNSNoticationCenter);
    [RCrashReporting appWillTerminate];
    OCMVerify([mockNSNoticationCenter removeObserver:[OCMArg any] name:[OCMArg any] object:[OCMArg any]]);
}

/**
 * ConfigServer class tests.
 */
- (void)testSetPreviousValues
{
    constants.prevIsEnabled = nil;
    XCTAssertEqualObjects(constants.prevIsEnabled, nil);
    constants.prevIsEnabled = [NSNumber numberWithBool:true];
    XCTAssertEqualObjects(constants.prevIsEnabled, [NSNumber numberWithBool:true]);
}

//  No previous sticky, no enabled, no sticky, no override.
- (void)testCheckEnable_1
{
    XCTAssertFalse([RCRConfigServer checkEnable:[NSNumber numberWithInt:0] responseSticky:[NSNumber numberWithInt:0] responseOverride:[NSNumber numberWithInt:0]]);
}

//  No previous sticky, yes enabled, no sticky, no override.
- (void)testCheckEnable_2
{
    XCTAssertTrue([RCRConfigServer checkEnable:[NSNumber numberWithInt:1]
                             responseSticky:[NSNumber numberWithInt:1]
                           responseOverride:[NSNumber numberWithInt:0]]);
}

//  No previous sticky, yes enabled, yes sticky, no override.
- (void)testCheckEnable_3
{
    XCTAssertTrue([RCRConfigServer checkEnable:[NSNumber numberWithInt:1]
                             responseSticky:[NSNumber numberWithInt:1]
                           responseOverride:[NSNumber numberWithInt:1]]);
    
    OCMVerify([defaults setObject:[NSNumber numberWithInt:1] forKey:@"enabled"]);
}

//  No previous sticky, no enabled, yes sticky, no override.
- (void)testCheckEnable_4
{
    XCTAssertFalse([RCRConfigServer checkEnable:[NSNumber numberWithInt:0]
                              responseSticky:[NSNumber numberWithInt:1]
                            responseOverride:[NSNumber numberWithInt:0]]);
    
    OCMVerify([defaults setObject:[NSNumber numberWithInt:1] forKey:@"enabled"]);
}

// No previous sticky, yes enabled, yes sticky, yes override.
- (void)testCheckEnable_5
{
    XCTAssertTrue([RCRConfigServer checkEnable:[NSNumber numberWithInt:1]
                             responseSticky:[NSNumber numberWithInt:0]
                           responseOverride:[NSNumber numberWithInt:1]]);
}

// Yes previous sticky, yes enabled, yes sticky, yes override.
- (void)testCheckEnable_6
{
    constants.prevIsEnabled = [NSNumber numberWithBool:true];
    XCTAssertTrue([RCRConfigServer checkEnable:[NSNumber numberWithInt:1]
                             responseSticky:[NSNumber numberWithInt:1]
                           responseOverride:[NSNumber numberWithInt:1]]);
    
    OCMVerify([defaults setObject:[NSNumber numberWithInt:1] forKey:@"enabled"]);
}

// Yes previous sticky, no enabled, yes sticky, yes override.
- (void)testCheckEnable_7
{
    constants.prevIsEnabled = [NSNumber numberWithBool:true];
    XCTAssertFalse([RCRConfigServer checkEnable:[NSNumber numberWithInt:0]
                              responseSticky:[NSNumber numberWithInt:1]
                            responseOverride:[NSNumber numberWithInt:1]]);
    
    OCMVerify([defaults setObject:[NSNumber numberWithInt:1] forKey:@"enabled"]);
}

// Yes previous sticky, no enabled, no sticky, yes override.
- (void)testCheckEnable_8
{
    constants.prevIsEnabled = [NSNumber numberWithBool:true];
    XCTAssertFalse([RCRConfigServer checkEnable:[NSNumber numberWithInt:0]
                              responseSticky:[NSNumber numberWithInt:0]
                            responseOverride:[NSNumber numberWithInt:1]]);
    XCTAssertFalse([defaults objectForKey:@"enabled"]);

}

// Yes previous sticky, yes enabled, no sticky, yes override.
- (void)testCheckEnable_9
{
    constants.prevIsEnabled = [NSNumber numberWithBool:true];
    XCTAssertTrue([RCRConfigServer checkEnable:[NSNumber numberWithInt:1]
                             responseSticky:[NSNumber numberWithInt:0]
                           responseOverride:[NSNumber numberWithInt:1]]);
}

// Yes previous sticky, yes enabled, no sticky, no override.
- (void)testCheckEnable_10
{
    constants.prevIsEnabled = [NSNumber numberWithBool:true];
    XCTAssertTrue([RCRConfigServer checkEnable:[NSNumber numberWithInt:1]
                             responseSticky:[NSNumber numberWithInt:0]
                           responseOverride:[NSNumber numberWithInt:0]]);
}

// Yes previous sticky (true), no enabled, no sticky, no override.
- (void)testCheckEnable_11
{
    constants.prevIsEnabled = [NSNumber numberWithBool:true];
    XCTAssertTrue([RCRConfigServer checkEnable:[NSNumber numberWithInt:0]
                             responseSticky:[NSNumber numberWithInt:0]
                           responseOverride:[NSNumber numberWithInt:0]]);
}

// Yes previous sticky (false), no enabled, no sticky, no override.
- (void)testCheckEnable_12
{
    constants.prevIsEnabled = [NSNumber numberWithBool:false];
    XCTAssertFalse([RCRConfigServer checkEnable:[NSNumber numberWithInt:0]
                              responseSticky:[NSNumber numberWithInt:0]
                            responseOverride:[NSNumber numberWithInt:0]]);
}

/**
 * CustomDefault class tests.
 */

// Test that the file is getting written.
- (void)testWriteCustomKeyValue_1
{
    NSMutableDictionary* customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertFalse([customKeysDict count]);
    XCTAssertTrue([RCRCustomDefault writeCustomKeyValue:keyForTesting forValue:@"hi"]);
    customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertTrue([customKeysDict objectForKey:keyForTesting]);
}

// Test key-value pair size is limited to only 64 pairs.
- (void)testWriteCustomKeyValue_2
{
    NSMutableDictionary* customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertFalse([customKeysDict count]);
    for (int i = 0;i < 66; i++)
    {
        BOOL resultBool = [RCRCustomDefault writeCustomKeyValue:[NSString stringWithFormat:@"%@", [NSNumber numberWithInt:i]]
                                  forValue:[NSString stringWithFormat:@"%@", [NSNumber numberWithInt:i]]];
        
        (i < 64) ? XCTAssertTrue(resultBool) : XCTAssertFalse(resultBool);
    }
    customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertTrue([customKeysDict count] < 65);
}

// Test that an individual key-value pair can not exceed one kilobyte.
- (void)testWriteCustomKeyValue_3
{
    NSMutableDictionary* customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertFalse([customKeysDict count]);
    
    NSString* veryLongString = @"";
    // Create a 1267 bytes string.
    for (int i = 0; i < 180; i++)
    {
        veryLongString = [veryLongString stringByAppendingString:@"testing"];
    }
    XCTAssertFalse([RCRCustomDefault writeCustomKeyValue:keyForTesting forValue:veryLongString]);
    customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertFalse([customKeysDict objectForKey:keyForTesting]);
}

// Test that key-value will not write if key is nil.
- (void)testWriteCustomKeyValue_4
{
    NSMutableDictionary* customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertFalse([customKeysDict count]);
    XCTAssertFalse([RCRCustomDefault writeCustomKeyValue:nil forValue:@""]);
}

// Test that setting value as 'nil' will save into the file.
- (void)testWriteCustomKeyValue_5
{
    NSMutableDictionary* customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertFalse([customKeysDict count]);
    XCTAssertTrue([RCRCustomDefault writeCustomKeyValue:keyForTesting forValue:nil]);
    customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertTrue([customKeysDict count]);
}

// Test if key gets removed from file.
- (void)testRemoveKeyValue
{
    NSMutableDictionary* customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertFalse([customKeysDict count]);
    [RCRCustomDefault writeCustomKeyValue:keyForTesting forValue:@"hi"];
    customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertTrue([customKeysDict count]);
    XCTAssertTrue([RCRCustomDefault removeKeyValue:keyForTesting]);
    customKeysDict = [defaults objectForKey:CUSTOM_KEY];
    XCTAssertFalse([customKeysDict count]);
}

// Test if logs are getting written correctly.
- (void)testWriteCustomLog_1
{
    NSMutableArray* customlogArr = [defaults objectForKey:CUSTOM_LOG];
    XCTAssertFalse([customlogArr count]);
    XCTAssertTrue([RCRCustomDefault writeCustomLog:@"One log message here"]);
    customlogArr = [defaults objectForKey:CUSTOM_LOG];
    XCTAssertTrue([customlogArr count]);
    
}

// Test that logs are not written if message is over one kilobyte.
- (void)testWriteCustomLog_2
{
    NSString* veryLongMessage = @"";
    // Create a 1267 bytes string.
    for (int i = 0; i < 180; i++)
    {
        veryLongMessage = [veryLongMessage stringByAppendingString:@"testing"];
    }
    NSMutableArray* customlogArr = [defaults objectForKey:CUSTOM_LOG];
    XCTAssertFalse([customlogArr count]);
    XCTAssertFalse([RCRCustomDefault writeCustomLog:veryLongMessage]);
    customlogArr = [defaults objectForKey:CUSTOM_LOG];
    XCTAssertFalse([customlogArr count]);
}

// Test that the oldest messages gets deleted when size exceeds the limit of 64 kilobytes.
    - (void)testWriteCustomLog_3
{
    NSString* size200BytesMsg = @"";
    for (int i = 0; i < 40; i++)
    {
        size200BytesMsg = [size200BytesMsg stringByAppendingString:@"11111"];
    }
    NSUInteger shortMessageInBytes = [size200BytesMsg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"short message: %tu", shortMessageInBytes);
    
    NSString* size1000BytesMsg = @"";
    for (int i = 0; i < 200; i++)
    {
        size1000BytesMsg = [size1000BytesMsg stringByAppendingString:@"hello"];
    }
    NSUInteger longMessageInBytes = [size1000BytesMsg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"long message: %tu", longMessageInBytes);
    
    // Fill first 1 kilobyte with short messages.
    for (int i = 0; i < 5; i++)
    {
        XCTAssertTrue([RCRCustomDefault writeCustomLog:size200BytesMsg]);
    }
    
    // Fill rest of 63 kilobytes with long messages
    for (int i = 0; i < 63; i++)
    {
        XCTAssertTrue([RCRCustomDefault writeCustomLog:size1000BytesMsg]);
    }
    
    NSMutableArray* customlogArr = [defaults objectForKey:CUSTOM_LOG];
    // Verify that there are 68 logs messages that makes up the 64 kilobyte at the moment.
    XCTAssertTrue([customlogArr count] == 68);

    // Write an additional 1 kilobyte message.
    XCTAssertTrue([RCRCustomDefault writeCustomLog:size1000BytesMsg]);
    
    // The additional message above should have removed the first
    // five 200 bytes messages in order to make room for the
    // 1000 bytes message.
    customlogArr = [defaults objectForKey:CUSTOM_LOG];
    XCTAssertTrue([customlogArr count] == 64);
}

@end
