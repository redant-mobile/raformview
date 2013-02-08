/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <UIKit/UIKit.h>

@interface RAFormTextEntryCell:UITableViewCell

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *messageField;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

- (IBAction)showInfo:(id)sender;

@end
