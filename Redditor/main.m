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
        RedditorEngine* eng = [[RedditorEngine alloc] init];
        [eng loginWithUsername:@"test1" andPassword:@"wrong"];
        if ([eng checkIfLoggedIn]) {
            NSLog(@"Successful");
        }
        else {
            NSLog(@"Fail");
        }
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
