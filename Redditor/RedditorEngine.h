/*
 RedditorEngine is a class that provides service to access the Reddit API
 Includes:
 * retreiving hot posts from Reddit
 */

#import <Foundation/Foundation.h>
#import "RedditPost.h"

@interface RedditorEngine : NSObject

-(NSArray*) retrieveHotRedditPostsFromSubReddit: (NSString*) sub;

@end

