//
//  AddLinkViewController.h
//  Redditor
//
//  Created by Eddie Lau on 5/4/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddLinkViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property NSString* sub;
@end
