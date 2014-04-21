//
//  RedditComment.h
//  Redditor
//
//  Created by Eddie Lau on 4/20/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedditComment : NSObject
@property NSString* name; // name of the "thing"
@property NSString* author;
@property NSInteger* ups;
@property NSInteger* downs;
@property NSString* body;
@property NSInteger* created_utc;
@property NSMutableArray* children;

-(void) addChild: (RedditComment*) comment;
-(id) initWithDict:(NSDictionary*) dict;
@end
