/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "RAFormViewController.h"
#import "RAFormSwitchCell.h"
#import "RAFormTextEntryCell.h"
#import "RAFormSecureTextEntryCell.h"
#import "RAFormTextSelectionCell.h"



#define UIBarButtonPlain(TITLE, SELECTOR) \
[[UIBarButtonItem alloc] initWithTitle : TITLE \
style : UIBarButtonItemStylePlain target : self action : SELECTOR]

#define UIColorMake(redValue, greenValue, blueValue) \
[UIColor colorWithRed : redValue/255.0f green : greenValue/255.0f blue : blueValue/255.0f alpha : 1.0]

#define UIColor_warningTextColor    UIColorMake(230, 0, 0)


@interface RAFormViewController ()
@property (nonatomic, weak) UITextField *activeField;
@property (nonatomic, strong) NSArray *keyboardType;
@property (nonatomic, strong) NSArray *autoCorrectStatus;
@property (nonatomic, strong) NSArray *autoCapitalizeStatus;
@property (nonatomic, strong) UIToolbar *buttonToolbar;
@property (nonatomic, strong) NSMutableArray* textFieldArray;
@property (nonatomic, strong) UIBarButtonItem *previousButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;

@end

@implementation RAFormViewController

@synthesize entries = _entries;
@synthesize delegate = _delegate;
@synthesize tableView = _tableView;

- (void)setValid:(BOOL)valid {
    if (_valid != valid) {
        _valid = valid;
        self.navigationItem.rightBarButtonItem.enabled = _valid;
    }
}

#pragma mark - Methods

- (id)initWithPlistNamed:(NSString *)plist {
    self = [super initWithNibName:@"RAFormViewController" bundle:[NSBundle mainBundle]];

    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.entries = [PListSerialisation dataFromBundledPlistNamed:plist];
    }
    
    self.keyboardType =
        [NSArray arrayWithObjects:@"UIKeyboardTypeDefault", @"UIKeyboardTypeASCIICapable", @"UIKeyboardTypeNumbersAndPunctuation", @"UIKeyboardTypeURL",
        @"UIKeyboardTypePhonePad", @"UIKeyboardTypeNumberPad", @"UIKeyboardTypeNamePhonePad", @"UIKeyboardTypeEmailAddress", nil];

    self.autoCapitalizeStatus =
        [NSArray arrayWithObjects:@"UITextAutocapitalizationTypeNone", @"UITextAutocapitalizationTypeWords", @"UITextAutocapitalizationTypeSentences",
        @"UITextAutocapitalizationTypeAllCharacters", nil];

    self.autoCorrectStatus = [NSArray arrayWithObjects:@"UITextAutocorrectionTypeDefault", @"UITextAutocorrectionTypeNo", @"UITextAutocorrectionTypeYes", nil];

    return self;
}

- (id)initWithPlistNamed:(NSString *)plist prefilledValues:(NSDictionary *)values {
    if (self = [self initWithPlistNamed:plist]) {
        for (NSDictionary *entry in self.entries) {
            [entry setValue:[values valueForKeyPath:[entry objectForKey:@"property"]] forKey:@"value"];
        }
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Register notification when the keyboard will be show
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification
        object:nil];

    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification
        object:nil];

    // Add tap recognizer for whole view (for keybaord dismissing)
    UITapGestureRecognizer *tapDetector = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(findAndResignFirstResponder)];
    tapDetector.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapDetector];
    self.navigationItem.rightBarButtonItem = UIBarButtonPlain(@"Submit", @selector(submitAction:));
    self.navigationItem.rightBarButtonItem.enabled = self.valid;
}

- (void)viewWillDisappear:(BOOL)animated {
    // Unregister notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [self.view findAndResignFirstResponder];

    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }

    self.activeField = nil;
    [super viewWillDisappear:animated];
}

- (void)setEntries:(NSMutableArray *)entries {
    if (_entries != entries) {
        _entries = entries;
        [self.tableView reloadData];
    }
}

- (void)validateAllFields {
    for (NSInteger i = 0; i < self.entries.count; i++) {
        if (![self fieldIsValidAtIndex:i]) {
            self.valid = NO;
            return;
        }
    }
    self.valid = YES;
}

- (void)showFieldInvalidMessage:(BOOL)shown index:(NSInteger)index {
    if (shown) {
        [[self.entries objectAtIndex:index] setObject:@"yes" forKey:@"showerror"];
    }
    else {
        [[self.entries objectAtIndex:index] setObject:@"no" forKey:@"showerror" ];
    }

    if (index < self.entries.count) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if ([cell isKindOfClass:[RAFormTextEntryCell class]] || [cell isKindOfClass:[RAFormSecureTextEntryCell class]]) {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }
}

- (BOOL)fieldIsValidAtIndex:(NSInteger)index {
    NSString *validation = [[self.entries objectAtIndex:index] objectForKey:@"validation"];
    NSString *type = [[self.entries objectAtIndex:index] objectForKey:@"cellIdentifier"];
    
    // Text
    if ([type isEqualToString:@"RAFormTextEntryCell"] || [type isEqualToString:@"RAFormSecureTextEntryCell"]) {
        if (validation) {
            NSString *value = [[self.entries objectAtIndex:index] objectForKey:@"value"];
            if (value && ![[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                NSError *error;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:validation
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                NSUInteger numberOfMatches = [regex numberOfMatchesInString:value
                                                                    options:0
                                                                      range:NSMakeRange(0, [value length])];
                if (numberOfMatches == 0) {
                    return NO;
                }
            }
            else if ([[[self.entries objectAtIndex:index] objectForKey:@"required"] boolValue]) {
                return NO;
            }
        }
    }
    
    // Picker
    else if ([type isEqualToString:@"RAFormTextSelectionCell"]) {
        if (![[self.entries objectAtIndex:index] objectForKey:@"value"]) {
            return NO;
        }
    }
    return YES;
}

- (void)submitAction:(id)sender {
    [self.view findAndResignFirstResponder];
    NSMutableArray *mutableEntries = [[NSMutableArray alloc] init];

    for (NSDictionary *entry in _entries) {
        if (entry && [entry objectForKey:@"value"]) {
            if ([entry objectForKey:@"value"]) {
                [mutableEntries addObject:[entry objectForKey:@"value"]];
            }
        }
        else {
            [mutableEntries addObject:@""];
        }
    }

    if ([self.delegate respondsToSelector:@selector(submitWithArray:)]) {
        [self.delegate submitWithArray:mutableEntries];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self.entries objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[cellData objectForKey:@"cellIdentifier"]];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:[cellData objectForKey:@"cellIdentifier"] owner:self options:nil] objectAtIndex:0];
        //cell = [[[NSBundle bundleWithPath:@"RAFormKit.bundle/Nibs"] loadNibNamed:[cellData objectForKey:@"cellIdentifier"] owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    UIKeyboardType keyboardType = [self.keyboardType indexOfObject:[cellData objectForKey:@"keyboardType"]];
    UITextAutocorrectionType autoCorrectStatus = [self.autoCorrectStatus indexOfObject:[cellData objectForKey:@"autoCorrectStyle"]];
    UITextAutocapitalizationType autoCapitalizeStatus = [self.autoCapitalizeStatus indexOfObject:[cellData objectForKey:@"autoCapitalizeType"]];

    if ([cell isKindOfClass:[RAFormSwitchCell class]]) {
        [((RAFormSwitchCell *)cell).switchView addTarget:self action:@selector(switchAction:)forControlEvents:UIControlEventValueChanged];
        [((RAFormSwitchCell *)cell).switchView setOn:[[cellData objectForKey:@"value"] boolValue]];
        ((RAFormSwitchCell *)cell).titleLabel.text = [cellData objectForKey:@"title"];
    }

    if ([cell isKindOfClass:[RAFormTextEntryCell class]]) {
        [((RAFormTextEntryCell *)cell).textField addTarget:self action:@selector(textChangedInTextField:) forControlEvents:UIControlEventEditingChanged];
        ((RAFormTextEntryCell *)cell).textField.placeholder = [cellData objectForKey:@"title"];
        ((RAFormTextEntryCell *)cell).textField.tag = indexPath.row;
        ((RAFormTextEntryCell *)cell).textField.delegate = self;
        ((RAFormTextEntryCell *)cell).textField.text = [cellData objectForKey:@"value"];
        ((RAFormTextEntryCell *)cell).textField.keyboardType = keyboardType;
        ((RAFormTextEntryCell *)cell).textField.autocorrectionType = autoCorrectStatus;
        ((RAFormTextEntryCell *)cell).textField.autocapitalizationType = autoCapitalizeStatus;
        ((RAFormTextEntryCell *)cell).messageField.textColor = UIColor_warningTextColor;
        if ([cellData objectForKey:@"error"]) {
            ((RAFormTextEntryCell *)cell).messageField.text = [cellData objectForKey:@"error"];
        }
        if ([[[self.entries objectAtIndex:indexPath.row] objectForKey:@"showerror"] isEqualToString:@"yes"]) {
            ((RAFormTextEntryCell *)cell).infoButton.hidden = NO;
        }
        else {
            ((RAFormTextEntryCell *)cell).infoButton.hidden = YES;
            ((RAFormTextEntryCell *)cell).messageField.hidden = YES;
        }
    }

    if ([cell isKindOfClass:[RAFormSecureTextEntryCell class]]) {
        [((RAFormSecureTextEntryCell *)cell).textField addTarget:self action:@selector(textChangedInTextField:) forControlEvents:UIControlEventEditingChanged];
        ((RAFormSecureTextEntryCell *)cell).textField.placeholder = [cellData objectForKey:@"title"];
        ((RAFormSecureTextEntryCell *)cell).textField.tag = indexPath.row;
        ((RAFormSecureTextEntryCell *)cell).textField.delegate = self;
        ((RAFormSecureTextEntryCell *)cell).textField.text = [cellData objectForKey:@"value"];
        ((RAFormSecureTextEntryCell *)cell).textField.keyboardType = keyboardType;
        ((RAFormSecureTextEntryCell *)cell).textField.autocorrectionType = autoCorrectStatus;
        ((RAFormSecureTextEntryCell *)cell).textField.autocapitalizationType = autoCapitalizeStatus;
        ((RAFormSecureTextEntryCell *)cell).messageField.textColor = UIColor_warningTextColor;
        if ([cellData objectForKey:@"error"]) {
            ((RAFormSecureTextEntryCell *)cell).messageField.text = [cellData objectForKey:@"error"];
        }
        if ([[[self.entries objectAtIndex:indexPath.row] objectForKey:@"showerror"] isEqualToString:@"yes"]) {
            ((RAFormSecureTextEntryCell *)cell).infoButton.hidden = NO;
        }
        else {
            ((RAFormSecureTextEntryCell *)cell).infoButton.hidden = YES;
            ((RAFormSecureTextEntryCell *)cell).messageField.hidden = YES;
        }
    }

    if ([cell isKindOfClass:[RAFormTextSelectionCell class]]) {
        if ([cellData objectForKey:@"value"]) {
            ((RAFormTextSelectionCell *)cell).currentSelectionLabel.text = [cellData objectForKey:@"value"];
        }
        else {
            ((RAFormTextSelectionCell *)cell).currentSelectionLabel.text = [cellData objectForKey:@"default"];
            ((RAFormTextSelectionCell *)cell).titleLabel.textColor = [UIColor lightGrayColor];

        }

        ((RAFormTextSelectionCell *)cell).titleLabel.text = [cellData objectForKey:@"title"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[RAFormTextSelectionCell class]]) {
        RAPickerViewController *vc = [[RAPickerViewController alloc] initWithNibName:@"RAPickerViewController" bundle:nil];
        vc.values = [[self.entries objectAtIndex:indexPath.row] objectForKey:@"values"];
        vc.delegate = self;
        self.navigationItem.backBarButtonItem = UIBarButtonPlain(@"Back", nil);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) resignKeyboard {
    [self.activeField resignFirstResponder];
}

- (void) buttonPressed:(id) sender {
    UITableViewCell *cell = (UITableViewCell *)[[self.activeField superview] superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSInteger newNext = [indexPath indexAtPosition:indexPath.length -1 ] + 1;
    NSIndexPath *plusPath = [[indexPath indexPathByRemovingLastIndex] indexPathByAddingIndex:newNext];
    
    NSInteger newPrevious = [indexPath indexAtPosition:indexPath.length - 1] - 1;
    NSIndexPath *previousPath = [[indexPath indexPathByRemovingLastIndex] indexPathByAddingIndex:newPrevious];
    
    NSIndexPath *selectedIndex;
    UITableViewCell *nextCell;
    if (sender == self.previousButton) {
        nextCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:previousPath];
        selectedIndex = previousPath;

    }
    else if (sender == self.nextButton) {
        nextCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:plusPath];
        selectedIndex = plusPath;
    }
    
    if ([nextCell isKindOfClass:[RAFormTextEntryCell class]] || [nextCell isKindOfClass:[RAFormSecureTextEntryCell class]]) {
        self.activeField = ((RAFormTextEntryCell *)nextCell).textField;
        [self.activeField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:selectedIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    else if ([nextCell isKindOfClass:[RAFormTextSelectionCell class]]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        RAPickerViewController *vc = [[RAPickerViewController alloc] initWithNibName:@"RAPickerViewController" bundle:nil];
        vc.values = [[self.entries objectAtIndex:selectedIndex.row] objectForKey:@"values"];
        vc.delegate = self;
        self.navigationItem.backBarButtonItem = UIBarButtonPlain(@"Back", nil);
        [self.activeField resignFirstResponder];
        [self.navigationController pushViewController:vc animated:YES];

    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
 
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    if (!self.buttonToolbar) {
        
        self.buttonToolbar = [[UIToolbar alloc] init] ;
        [self.buttonToolbar setBarStyle:UIBarStyleBlackOpaque];
        [self.buttonToolbar sizeToFit];
        self.previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed:)];
        self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed:)];
        UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        NSArray *itemsArray = [NSArray arrayWithObjects:self.previousButton, self.nextButton, flexibleSpace, doneButton, nil];
        
        [self.buttonToolbar setItems:itemsArray];
        
    }
    [self.activeField setInputAccessoryView:self.buttonToolbar];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text) {
        [[self.entries objectAtIndex:textField.tag] setObject:textField.text forKey:@"value"];
    }

    [textField resignFirstResponder];

    if ([self fieldIsValidAtIndex:textField.tag]) {
        [self showFieldInvalidMessage:NO index:textField.tag];
        [self validateAllFields];
    }
    else {
        [self showFieldInvalidMessage:YES index:textField.tag];
        self.valid = NO;
    }
}

- (void)textChangedInTextField:(UITextField *)textField {
    if (textField.text) {
        [[self.entries objectAtIndex:textField.tag] setObject:textField.text forKey:@"value"];
    }
    if ([self fieldIsValidAtIndex:textField.tag]) {
        id object = [[textField superview] superview];
        if ([object respondsToSelector:@selector(infoButton)]) {
            [[object infoButton] setHidden:YES];
        }

        [self validateAllFields];
    }
    else {
        id object = [[textField superview] superview];
        if ([object respondsToSelector:@selector(infoButton)]) {
            [[object infoButton] setHidden:NO];
        }
        self.valid = NO;
    }
}

#pragma mark - UISwitch handling

- (void)switchAction:(UIView *)sender {
    UISwitch *switchView = (UISwitch *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[switchView superview] superview];

    [[self.entries objectAtIndex:[self.tableView indexPathForCell:cell].row] setObject:[NSNumber numberWithBool:switchView.isOn] forKey:@"value"];
    NSLog(@"Setting -%c- on -%@-", switchView.isOn, [[self.entries objectAtIndex:[self.tableView indexPathForCell:cell].row] objectForKey:@"title"]);
}

#pragma mark - RAPickerViewControllerDelegate

- (void)didSelectValue:(NSString *)value {
    [[self.entries objectAtIndex:[self.tableView indexPathForSelectedRow].row] setObject:value forKey:@"value"];
    NSLog(@"Setting -%@- on -%@-", value, [[self.entries objectAtIndex:[self.tableView indexPathForSelectedRow].row] objectForKey:@"title"]);
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForSelectedRows] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.navigationController popViewControllerAnimated:YES];

    if ([self fieldIsValidAtIndex:[self.tableView indexPathForSelectedRow].row]) {
        [self showFieldInvalidMessage:NO index:[self.tableView indexPathForSelectedRow].row];
        [self validateAllFields];
    }
    else {
        [self showFieldInvalidMessage:YES index:[self.tableView indexPathForSelectedRow].row];
        self.valid = NO;
    }

}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;

    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.tableView.frame;

            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                frame.size.height -= keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height;
            }
            else {
                frame.size.height -= keyboardBounds.size.width - self.tabBarController.tabBar.frame.size.height;
            }

            self.tableView.frame = frame;

            // Scroll to make the cell visible
            if (self.activeField) {
                UITableViewCell *cell = (UITableViewCell *)[[self.activeField superview] superview];
                [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect keyboardBounds;

    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.tableView.frame;

            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                frame.size.height += keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height;
            }
            else {
                frame.size.height += keyboardBounds.size.width - self.tabBarController.tabBar.frame.size.height;
            }

            self.tableView.frame = frame;
        }];
}

@end
