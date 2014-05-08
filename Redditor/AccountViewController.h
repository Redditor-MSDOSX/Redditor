//
//  AccountViewController.h
//  Redditor
//
//  Created by Eddie Lau on 5/3/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *loggedInView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIView *loggedOutView;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (nonatomic, assign) id delegate;
- (IBAction)loginClicked:(id)sender;

- (IBAction)logoutClicked:(id)sender;
@end
