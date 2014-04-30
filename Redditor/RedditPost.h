/*
 RedditPost is a class that represent a post on Reddit, it can be used for retreving and posting Reddit posts
*/

#import <Foundation/Foundation.h>

@interface RedditPost : NSObject
@property NSString* title;
@property NSString* thumbnail;
@property NSInteger* ups;
@property NSInteger* downs;
@property NSString* name; // name of the "thing"
@property NSString* permalink;
@property NSString* author;
@property NSString* url;
@property NSInteger created_utc;
@property NSString* selfText;

-(id) initWithDict: (NSDictionary*) dict;
@end
