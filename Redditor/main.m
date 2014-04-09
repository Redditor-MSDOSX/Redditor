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
        RedditorEngine* eng = [[RedditorEngine alloc] init];
        [eng retrieveHotRedditPostsFromSubReddit:@""];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
