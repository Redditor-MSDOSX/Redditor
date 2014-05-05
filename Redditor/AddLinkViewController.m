//
//  AddLinkViewController.m
//  Redditor
//
//  Created by Eddie Lau on 5/4/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import "AddLinkViewController.h"
#import "RedditorEngine.h"

@interface AddLinkViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *progress;
@property (weak, nonatomic) IBOutlet UIImageView *captcha;

@end

@implementation AddLinkViewController

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
    self.title = @"Add New Link!";
    self.progress.center = self.view.center;
    [self.progress setHidesWhenStopped:YES];
    [self.view addSubview:self.progress];
    [self.progress startAnimating];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if (![RedditorEngine checkIfLoggedIn]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                        message:@"Please log in first!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    /* loads the captcha */
    RedditorEngine* eng = [[RedditorEngine alloc] init];

    NSString* iden = [eng getIdenForCaptcha];
    UIImage* img = [eng getCaptchaWithIden:iden];
    self.captcha.image = img;
    [self.progress stopAnimating];
                              
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
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
