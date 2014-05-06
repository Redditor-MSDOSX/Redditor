//
//  ReplyViewController.m
//  Redditor
//
//  Created by Eddie Lau on 5/5/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import "ReplyViewController.h"
#import "RedditorEngine.h"

@interface ReplyViewController ()
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property (weak, nonatomic) IBOutlet UITextView *comment;

@end

@implementation ReplyViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.comment.layer.borderColor = [[UIColor grayColor] CGColor];
    self.comment.layer.borderWidth = 1.0;
    self.comment.layer.cornerRadius = 10;
    //self.comment.text = self.fullname;
    self.submit.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![RedditorEngine checkIfLoggedIn]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                        message:@"Please log in first!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    self.submit.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)submitButtonClicked:(id)sender {
    if ([self.comment.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                        message:@"Please type something"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        RedditorEngine* eng = [[RedditorEngine alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        [data setObject:@"json" forKey:@"api_type"];
        [data setObject:self.comment.text forKey:@"text"];
        [data setObject:self.fullname forKey:@"thing_id"];
        if ([eng replyWith:data]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:@"Added Comment!"
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
        }
    }
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
