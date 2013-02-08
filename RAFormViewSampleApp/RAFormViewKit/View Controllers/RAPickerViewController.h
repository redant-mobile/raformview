/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */


@protocol RAPickerViewControllerDelegate
- (void)didSelectValue:(NSString *)value;
@end

@interface RAPickerViewController:UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *values;
@property (nonatomic, weak) id<RAPickerViewControllerDelegate>delegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
