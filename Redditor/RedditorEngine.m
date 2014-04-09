/*
 RedditorEngine is a class that provides service to access the Reddit API
 Includes:
    * reading hot posts from Reddit
*/

#import "RedditorEngine.h"
#import "RedditAPIConnector.h"
#import "RedditPost.h"

@implementation RedditorEngine

/* 
 retrieveHotRedditPostsFromSubReddit method retrieves a list of hot posts and returns them as a NSArray of RedditPost object
 if no subreddit is given the root reddit will be retrieved 
*/
-(NSArray*) retrieveHotRedditPostsFromSubReddit: (NSString*) sub {
    return [self retrieve:@"hot" PostsFrom:sub];
}

/*
 retrieveNewRedditPostsFromSubReddit method retrieves a list of hot posts and returns them as a NSArray of RedditPost object
 if no subreddit is given the root reddit will be retrieved
 */
-(NSArray*) retrieveNewRedditPostsFromSubReddit: (NSString*) sub {
    return [self retrieve:@"new" PostsFrom:sub];
}

/*
 retrieveRisingRedditPostsFromSubReddit method retrieves a list of hot posts and returns them as a NSArray of RedditPost object
 if no subreddit is given the root reddit will be retrieved
 */
-(NSArray*) retrieveRisingRedditPostsFromSubReddit: (NSString*) sub {
    return [self retrieve:@"rising" PostsFrom:sub];
}

/*
 retrieveControversialRedditPostsFromSubReddit method retrieves a list of hot posts and returns them as a NSArray of RedditPost object
 if no subreddit is given the root reddit will be retrieved
 */
-(NSArray*) retrieveControversialRedditPostsFromSubReddit: (NSString*) sub {
    return [self retrieve:@"controversial" PostsFrom:sub];
}

/*
 retrieveTopRedditPostsFromSubReddit method retrieves a list of hot posts and returns them as a NSArray of RedditPost object
 if no subreddit is given the root reddit will be retrieved
 */
-(NSArray*) retrieveTopRedditPostsFromSubReddit: (NSString*) sub {
    return [self retrieve:@"top" PostsFrom:sub];
}


/*
 internal method to retrieve posts
*/
-(NSArray*) retrieve :(NSString*) type PostsFrom: (NSString*) sub {
    NSData* data = nil;
    if ([sub isEqualToString:@""]) {
        data = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/%@.json", type]]];
    }
    else {
        data = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString: [NSString stringWithFormat:@"http://www.reddit.com/r/%@/%@.json", sub, type]]];
    }
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSMutableArray* returnData = [[NSMutableArray alloc] init];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON response.");
    }
    else {
        NSDictionary* temp1 = [json objectForKey:@"data"];
        NSArray* list = [temp1 objectForKey:@"children"];
        for (NSDictionary* item in list) {
            NSLog([[item objectForKey:@"data" ] objectForKey:@"title" ]);
            [returnData addObject: [[RedditPost alloc] initWithDict:[item objectForKey:@"data"]]];
        }
        
    }
    return [NSArray arrayWithArray:returnData];
}



@end