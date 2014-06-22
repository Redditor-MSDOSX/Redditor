//
//  AccountViewController.m
//  Redditor
//
//  Created by Eddie Lau on 5/3/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import "AccountViewController.h"
#import "SWRevealViewController.h"
#import "RedditorEngine.h"
#import "SidebarViewController.h"
#import "RegisterViewController.h"

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation AccountViewController

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
    // Change button color
    //_sidebarButton.tintColor = [UIColor colorWithWhite:0.1f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);

    // Set the gesture
    [self.container addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    if ([RedditorEngine checkIfLoggedIn]) {
        NSString* cellText = [RedditorEngine getUsername];
        
        
        self.userName.text = cellText;
        [self.container addSubview:self.loggedInView];
    }
    else {
        [self.container addSubview:self.loggedOutView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)loginClicked:(id)sender {
    if (![RedditorEngine checkIfLoggedIn]) {
        [RedditorEngine loginWithUsername:_username.text andPassword:_password.text];
    }
    if ([RedditorEngine checkIfLoggedIn]) {
        [self.loggedOutView removeFromSuperview];
        self.userName.text = [RedditorEngine getUsername]; // update the username after logged in.
        [self.container addSubview: self.loggedInView];
        [((SidebarViewController*)self.delegate) updateSubscription]; // call the sidebar to update subscription after logged in
        [((SidebarViewController*)self.delegate).tableView reloadData];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                                             message:@"Cannot log in user, please try again!"
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
        [alert show];
        _password.text = @"";
    }
}

- (IBAction)logoutClicked:(id)sender {
    if ([RedditorEngine checkIfLoggedIn]) {
        [RedditorEngine logoutUser];
    }
    [self.loggedInView removeFromSuperview];
    [self.container addSubview:self.loggedOutView];
    [((SidebarViewController*)self.delegate) updateSubscription];
    [((SidebarViewController*)self.delegate).tableView reloadData];
}

/* trying to hide keyboard */
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Hi");
    [self.view endEditing:YES]; // dismiss the keyboard
    
    [super touchesBegan:touches withEvent:event];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"register_segue"]) {
        RegisterViewController* dest = (RegisterViewController*)segue.destinationViewController;
        dest.delegate = self;
    }
    [super prepareForSegue:segue sender:sender];
}

- (void) reloadView {
    if ([RedditorEngine checkIfLoggedIn]) {
        [self.container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.userName.text = [RedditorEngine getUsername];
        [self.container addSubview:self.loggedInView];
    }
    else {
        [self.container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.container addSubview:self.loggedOutView];
    }
}
@end
