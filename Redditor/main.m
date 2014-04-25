//
//  main.m
//  Redditor
//
//  Created by Eddie Lau on 4/1/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "RedditorEngine.h"
int main(int argc, char * argv[])
{
    @autoreleasepool {
        /* just playing around here */
        /*
        RedditorEngine* eng = [[RedditorEngine alloc] init];
        
        BOOL login = [eng loginWithUsername:@"redditortesting" andPassword:@"password"];
        if (login) {
            NSLog(@"Successful log in");
        }
        else {
            NSLog(@"Failed log in");
        }
        
        if ([eng checkIfLoggedIn]) {
            NSLog(@"Successful");
        }
        else {
            NSLog(@"Fail");
        }*/
        /*
        NSString* iden = [eng getIdenForCaptcha];
        NSLog(iden);
        UIImage* img = [eng getCaptchaWithIden:iden];
        
        NSLog([NSString stringWithFormat:@"%.2f",[img size].height ]);
        [eng searchPostsWithKeyword:@"test" InSubReddit:@""];
        */
        /*
        [eng logoutUser];
        if (![eng checkIfLoggedIn]) {
            NSLog(@"Successful");
        }
        else {
            NSLog(@"Fail");
        }
        */
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
