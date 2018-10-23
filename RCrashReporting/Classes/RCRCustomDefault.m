#import "RCRCustomDefault.h"
#import "RCRConstants.h"

@implementation RCRCustomDefault

+ (BOOL)writeCustomKeyValue:(NSString*)key forValue:(NSString*)value
{
    if (key == nil)
    {
        NSLog(@"Cannot enter an empty key.");
        return false;
    }
    NSString* keyToInsert = key;
    if ([keyToInsert isEqualToString:@"log"])
    {
        keyToInsert = @"log_";
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* customKeyPairDict = [[NSMutableDictionary alloc] init];
    
    if ([defaults objectForKey:CUSTOM_KEY])
    {
        customKeyPairDict = [[defaults objectForKey:CUSTOM_KEY] mutableCopy];
    }
    
    if ([customKeyPairDict count] >= 64)
    {
        // Custom key should have a maximum of 64 key-pair values.
        NSLog(@"Can only have 64 key-value pairs. Current count: %lu", [customKeyPairDict count]);
        return false;
    }
    
    NSUInteger keyInBytes = [keyToInsert lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger valueInBytes = [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    // Check if key and pair value together is over one kilobyte in size.
    if ((keyInBytes + valueInBytes) > 1000)
    {
        NSLog(@"Key-value pair size exceeds 1 kilobyte. Current size: %lu", keyInBytes + valueInBytes);
        return false;
    }
    
    if (value == nil)
    {
        [customKeyPairDict setValue:@"NULL" forKey:keyToInsert];
    }
    else
    {
        [customKeyPairDict setValue:value forKey:keyToInsert];
    }
    
    [defaults setObject:customKeyPairDict forKey:CUSTOM_KEY];
    return true;
}

+ (BOOL)removeKeyValue:(NSString*)key
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dictionary = [[defaults objectForKey:CUSTOM_KEY] mutableCopy];
    
    if ([dictionary count] && [dictionary objectForKey:key])
    {
        [dictionary removeObjectForKey:key];
        [defaults setObject:dictionary forKey:CUSTOM_KEY];
        return true;
    }
    return false;
}

+ (BOOL)writeCustomLog:(NSString*)message
{
    NSUInteger messageInBytes = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (messageInBytes > 1000)
    {
        NSLog(@"Message size exceeds 1 kilobyte. Current size: %lu", messageInBytes);
        return false;
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* customLogArray = [[NSMutableArray alloc] init];
    
    if ([defaults objectForKey:CUSTOM_LOG])
    {
        customLogArray = [[defaults objectForKey:CUSTOM_LOG] mutableCopy];
    }
    
    [customLogArray addObject:message];
    
    // If total bytes exceeds 64 kilobyte limit.
    NSUInteger totalBytes = [self calculateTotalSizeInBytes:customLogArray];
    NSUInteger maxCapacity = (NSUInteger)64000;
    while (totalBytes > maxCapacity)
    {
        [customLogArray removeObjectAtIndex:0];
        totalBytes = [self calculateTotalSizeInBytes:customLogArray];
    }
    
    [defaults setObject:customLogArray forKey:CUSTOM_LOG];
    return true;
}

/**
 * Returns the current size in
 * bytes of previous log messages.
 * Param is the array that is holding all log messages.
 */
+ (NSUInteger)calculateTotalSizeInBytes:(NSMutableArray*)array
{
    NSUInteger totalBytesInArray = 0;
    // Calculate current size in bytes.
    for (id ele in array)
    {
        totalBytesInArray += [ele lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    }
    return totalBytesInArray;
}

@end
