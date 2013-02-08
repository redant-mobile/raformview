/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SampleFormViewController.h"

@interface SampleFormViewController ()

@end

@implementation SampleFormViewController

- (id)initWithPlistNamed:(NSString *)plist {
    if (self = [super initWithPlistNamed:plist]) {
        self.title = @"Sample Form";
        self.delegate = self;
    }
    
    return self;
}


- (id)initWithPlistNamed:(NSString *)plist prefilledValues:(NSDictionary *)values {
    if (self = [super initWithPlistNamed:plist prefilledValues:values]) {
        self.title = @"Sample Form";
        self.delegate = self;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.titles = [NSArray arrayWithObjects:@"Mr", @"Mrs", @"Miss", @"Dr", nil];
    self.countries = [NSArray arrayWithObjects:@"United Kingdom", @"Brazil", @"China", @"Switzerland", nil];
    self.cardTypes = [NSArray arrayWithObjects:@"Visa", @"Master Card", nil];
}

- (NSArray *)titles {
    return [[self.entries objectAtIndex:3] objectForKey:@"values"];
}


- (void)setTitles:(NSArray *)titles {
    [[self.entries objectAtIndex:3] setObject:titles forKey:@"values"];
    [self.tableView reloadData];
}


- (NSArray *)countries {
    return [[self.entries objectAtIndex:10] objectForKey:@"values"];
}


- (void)setCountries:(NSArray *)countries {
    [[self.entries objectAtIndex:10] setObject:countries forKey:@"values"];
    [self.tableView reloadData];
}

- (NSArray *)cardTypes {
    return [[self.entries objectAtIndex:0] objectForKey:@"values"];
}


- (void)setCardTypes:(NSArray *)cardTypes {
    [[self.entries objectAtIndex:0] setObject:cardTypes forKey:@"values"];
    [self.tableView reloadData];
}

#pragma mark - FormView Controller Delegate methods
- (void)submitWithArray:(NSArray *)array {
    NSLog(@"Submitted form :\n%@", array);
}

@end
