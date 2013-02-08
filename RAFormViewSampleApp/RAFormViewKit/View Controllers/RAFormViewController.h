/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */


#import "RAPickerViewController.h"
#import "RAFormViewControllerDelegate.h"

@interface RAFormViewController:UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, RAPickerViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *entries;
@property (nonatomic, readonly) BOOL valid;
@property (nonatomic, weak) id<RAFormViewControllerDelegate>delegate;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (id)initWithPlistNamed:(NSString *)plist;
- (id)initWithPlistNamed:(NSString *)plist prefilledValues:(NSDictionary *)values;

@end
