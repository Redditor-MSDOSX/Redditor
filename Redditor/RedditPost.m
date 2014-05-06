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
        self.ups = [[dict objectForKey:@"ups"] intValue];
        self.downs = [[dict objectForKey:@"downs"] intValue];
        self.name = [dict objectForKey:@"name"];
        self.permalink = [dict objectForKey:@"permalink"];
        self.author = [dict objectForKey:@"author"];
        self.url = [dict objectForKey:@"url"];
        self.created_utc = [[dict objectForKey:@"created_utc"] intValue];
        self.selfText = [dict objectForKey:@"selftext"];
        self.is_self = [dict objectForKey:@"is_self"];
        self.num_comments = [[dict objectForKey:@"num_comments"] intValue];
        self.over_18 = [dict objectForKey:@"over_18"];
    }
    return self;
    
}
@end
