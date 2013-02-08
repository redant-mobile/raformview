/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "PListSerialisation.h"

@implementation PListSerialisation

+ (id)dataFromBundledPlistNamed:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];

    NSString *errorDesc = nil;
    NSPropertyListFormat format;

    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];

    id dictionary = [NSPropertyListSerialization
        propertyListFromData:plistXML
        mutabilityOption:NSPropertyListMutableContainersAndLeaves
        format:&format
        errorDescription:&errorDesc];

    if (!dictionary) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }

    return dictionary;
}


+ (id)dataFromPlistAtPath:(NSURL *)filePath {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;

    NSData *plistXML = [NSData dataWithContentsOfURL:filePath];

    id dictionary = [NSPropertyListSerialization
        propertyListFromData:plistXML
        mutabilityOption:NSPropertyListMutableContainersAndLeaves
        format:&format
        errorDescription:&errorDesc];

    if (!dictionary) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }

    return dictionary;
}


+ (id)propertyListFromString:(NSString *)response {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;

    NSData *plistXML = [response dataUsingEncoding:NSUTF8StringEncoding];

    id dictionary = [NSPropertyListSerialization
        propertyListFromData:plistXML
        mutabilityOption:NSPropertyListMutableContainersAndLeaves
        format:&format
        errorDescription:&errorDesc];

    if (!dictionary) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }

    return dictionary;
}


@end
