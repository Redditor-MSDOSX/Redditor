//
//  RegisterViewController.m
//  Redditor
//
//  Created by Eddie Lau on 5/8/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import "RegisterViewController.h"
#import "RedditorEngine.h"
#import "AccountViewController.h"
@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *pass;
@property (weak, nonatomic) IBOutlet UITextField *pass2;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *captcha;
@property (weak, nonatomic) IBOutlet UIImageView *captchaImg;
@property NSString* iden;
@property (weak, nonatomic) IBOutlet UIButton *submit;

@end

@implementation RegisterViewController {
}

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
    self.submit.enabled = NO;
    [self.indicator startAnimating];
    self.indicator.hidesWhenStopped = YES;
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /* loads the captcha */
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    
    self.iden = [eng getIdenForCaptcha];
    UIImage* img = [eng getCaptchaWithIden:self.iden];
    self.captchaImg.image = img;
    [self.indicator stopAnimating];
    self.submit.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (IBAction)registerButtonClicked:(id)sender {
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setObject:@"json" forKey:@"api_type"];
    [data setObject:self.iden forKey:@"iden"];
    [data setObject:self.username.text forKey:@"user"];
    [data setObject:self.pass.text forKey:@"passwd"];
    [data setObject:self.pass2.text forKey:@"passwd2"];
    [data setObject:@"True" forKey:@"rem"];
    [data setObject:self.email.text forKey:@"email"];
    [data setObject:self.captcha.text forKey:@"captcha"];
    BOOL result = [RedditorEngine registerUserWith:data];
    if (result) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                        message:@"Registered!"
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
        self.pass.text = @"";
        self.pass2.text = @"";
        self.captcha.text = @"";

    }
}

- (void) reloadCaptcha {
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    self.iden = [eng getIdenForCaptcha];
    self.captchaImg.image = [eng getCaptchaWithIden:self.iden];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [((AccountViewController*) self.delegate) reloadView];
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
