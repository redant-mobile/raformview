/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>

@interface PListSerialisation:NSObject

+ (id)dataFromBundledPlistNamed:(NSString *)filename;
+ (id)propertyListFromString:(NSString *)response;
+ (id)dataFromPlistAtPath:(NSURL *)filePath;

@end
