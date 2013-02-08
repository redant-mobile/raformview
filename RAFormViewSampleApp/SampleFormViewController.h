/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "RAFormViewController.h"

@interface SampleFormViewController : RAFormViewController<RAFormViewControllerDelegate>

- (id)initWithPlistNamed:(NSString *)plist prefilledValues:(NSDictionary *)values;

@property (nonatomic, weak) NSArray *titles;
@property (nonatomic, weak) NSArray *countries;
@property (nonatomic, weak) NSArray *cardTypes;

@end
