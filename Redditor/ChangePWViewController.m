//
//  ChangePWViewController.m
//  Redditor
//
//  Created by Eddie Lau on 5/7/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import "ChangePWViewController.h"
#import "RedditorEngine.h"

@interface ChangePWViewController ()
@property (weak, nonatomic) IBOutlet UITextField *curpass;
@property (weak, nonatomic) IBOutlet UITextField *newpass;
@property (weak, nonatomic) IBOutlet UITextField *verpass;

@end

@implementation ChangePWViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Change Password";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (IBAction)changePWButtonClicked:(id)sender {
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    if ([eng changePasswordCurr:self.curpass.text New:self.newpass.text Ver:self.verpass.text]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                        message:@"Changed password!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                        message:@"Please try again!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.curpass.text = @"";
        self.newpass.text = @"";
        self.verpass.text = @"";
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[self navigationController] popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
