/*
 RedditPost is a class that represent a post on Reddit, it can be used for retreving and posting Reddit posts
 */

#import "RedditPost.h"

@implementation RedditPost
-(id) initWithDict:(NSDictionary *)dict {
    
    self = [super init];
    if (self!=nil) {
        self.title = [dict objectForKey:@"title"];
        self.thumbnail = [dict objectForKey:@"thumbnail"];
        self.ups = [dict objectForKey:@"ups"];
        self.downs = [dict objectForKey:@"downs"];
        self.name = [dict objectForKey:@"name"];
        self.permalink = [dict objectForKey:@"permalink"];
        self.author = [dict objectForKey:@"author"];
        self.url = [dict objectForKey:@"url"];
    }
    return self;
    
}
@end
