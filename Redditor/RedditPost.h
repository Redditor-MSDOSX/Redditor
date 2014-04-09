/*
 RedditPost is a class that represent a post on Reddit, it can be used for retreving and posting Reddit posts
*/

#import <Foundation/Foundation.h>

@interface RedditPost : NSObject
@property NSString* title;
@property NSString* thumbnail;
@property NSString* ups;
@property NSString* downs;
@property NSString* name;
@property NSString* permalink;
@property NSString* author;
@property NSString* url;

-(id) initWithDict: (NSDictionary*) dict;
@end
