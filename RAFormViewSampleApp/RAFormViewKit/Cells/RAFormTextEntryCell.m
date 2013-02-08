/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "RAFormTextEntryCell.h"

@implementation RAFormTextEntryCell

- (void)setup {
    self.textField.text = @"";
    self.messageField.text = @"";
    self.messageField.font = [UIFont fontWithName : @ "HelveticaNeue-Medium" size : 10.0f];
    self.messageField.textColor = [UIColor redColor];
    self.messageField.hidden = YES;
    self.infoButton.hidden = YES;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self setup];
    }

    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)showInfo:(id)sender {
    self.messageField.hidden = !self.messageField.hidden;
}

@end
