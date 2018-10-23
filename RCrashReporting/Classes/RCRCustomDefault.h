#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * CustomDefault.h
 * Class is used to handle condition checking and writing
 * and removing custom key-pair values in NSUserDefaults.
 */
@interface RCRCustomDefault : NSObject

/**
 * Given a string key and a string value, write to NSUserDefaults the key-value pair.
 * Method also checks that only 64 key-value pairs are stored at any given time.
 * It will not store if there are already 64 pairs stored. Also checks that each individual
 * key-value pairs are under 1024 bytes (1 kilobyte) in size before writing.
 * Returns true if key-value is written successfully, else return false.
 */
+ (BOOL)writeCustomKeyValue:(NSString*)key forValue:(NSString*)value;

/**
 * Given a string key, remove that key from NSUserDefaults.
 * Returns true is removal is successful, else return false.
 */
+ (BOOL)removeKeyValue:(NSString*)key;

/**
 * Given a string message, add that key to NSUserDefaults assuming
 * that the message is less than 1 kilobyte big when UTF8 encoded.
 * The method also checks for the bytes of previous log messages
 * and will repeatedly remove the object in front until the sum of all
 * previous messages and the newly added one is under 64 kilobytes.
 */
+ (BOOL)writeCustomLog:(NSString*)message;

@end

NS_ASSUME_NONNULL_END
