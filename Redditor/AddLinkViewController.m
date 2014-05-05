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
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *progress;
@property (weak, nonatomic) IBOutlet UILabel *urlTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *captcha;
@property NSString* iden;

@property (weak, nonatomic) IBOutlet UITextField *captchaField;
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

    self.iden = [eng getIdenForCaptcha];
    UIImage* img = [eng getCaptchaWithIden:self.iden];
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
/* submit button clicked */
- (IBAction)submitButtonClicked:(id)sender {
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    if (self.segment.selectedSegmentIndex == 0) {
        // adding link
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        [data setObject:@"json" forKey:@"api_type"];
        [data setObject:self.captchaField.text forKey:@"captcha"];
        [data setObject:@"link" forKey:@"kind"];
        [data setObject:self.sub forKey:@"sr"];
        [data setObject:self.titleField.text forKey:@"title"];
        [data setObject:self.urlTextField.text forKey:@"url"];
        [data setObject:self.iden forKey:@"iden"];
        [data setObject:[NSNumber numberWithBool:NO] forKey:@"resubmit"];
        [data setObject:[NSNumber numberWithBool:YES] forKey:@"save"];
        [data setObject:[NSNumber numberWithBool:NO] forKey:@"sendreplies"];
        BOOL result = [eng addLinkWith:data];
        if (result) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:@"Added Link!"
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
            [self reloadCaptcha];
        }
    }
    else {
        // adding text
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        [data setObject:@"json" forKey:@"api_type"];
        [data setObject:self.captchaField.text forKey:@"captcha"];
        [data setObject:@"self" forKey:@"kind"];
        [data setObject:self.sub forKey:@"sr"];
        [data setObject:self.titleField.text forKey:@"title"];
        [data setObject:self.urlTextField.text forKey:@"text"];
        [data setObject:self.iden forKey:@"iden"];
        [data setObject:[NSNumber numberWithBool:NO] forKey:@"resubmit"];
        [data setObject:[NSNumber numberWithBool:YES] forKey:@"save"];
        [data setObject:[NSNumber numberWithBool:NO] forKey:@"sendreplies"];
        BOOL result = [eng addTextWith:data];
        //[eng addTextWith:data toSub:@""];
        if (result) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:@"Added post!"
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
            [self reloadCaptcha];
        }
    }
}

/* segment control event */
- (IBAction)selectionIndexChanged:(id)sender {
    if (((UISegmentedControl*)sender).selectedSegmentIndex == 0) {
        self.urlTextLabel.text = @"URL";
    }
    else {
        self.urlTextLabel.text = @"Text";
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void) reloadCaptcha {
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    self.iden = [eng getIdenForCaptcha];
    self.captcha.image = [eng getCaptchaWithIden:self.iden];
}

@end
