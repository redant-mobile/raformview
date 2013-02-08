/*
 * RAForm
 * (c) Red Ant <mobile.support@redant.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "FirstViewController.h"
#import "SampleFormViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSampleForm:(id)sender {
    SampleFormViewController *vc = [[SampleFormViewController alloc] initWithPlistNamed:@"SampleForm"
                                                                        prefilledValues:[NSDictionary dictionaryWithObjectsAndKeys:@"Mr", @"title", nil]];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
