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

/*
 retrieve comment tree of an article id by ID36
 */
-(RedditComment*) retrieveCommentTreeFromArticle:(NSString *)id FocusAt: (NSString *)root{
    /* root of the comment of tree */
    RedditComment* rootComment = [[RedditComment alloc] init];
    
    /* try to make an API call */
    NSData* data = nil;
    if ([root isEqualToString:@""]) {
        data = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/comments/%@.json", id]]];
    }
    else {
        data = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/comments/%@.json?comment=%@", id, root]]];
    }
    NSError* error = nil;
    NSArray* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON response.");
    }
    else {
        NSArray* commentList = [[[json objectAtIndex:1] objectForKey:@"data"] objectForKey:@"children"];
        
        [self constructTreeWithListing:commentList atRoot:rootComment];
    }
    
    return rootComment;
}

/* a DFS to construct the comment tree */
-(void) constructTreeWithListing: (NSArray*)list atRoot: (RedditComment*) root {
    for (NSDictionary* comment in list) {
        if ([[comment objectForKey:@"kind"] isEqualToString:@"t1"]) {
            //NSLog([[comment objectForKey:@"data"] objectForKey:@"body"]);
            RedditComment* cm = [[RedditComment alloc] initWithDict:[comment objectForKey:@"data"]];
            NSDictionary* replies =[comment objectForKey:@"data"];
            if ([[replies valueForKey:@"replies"] isKindOfClass:[NSDictionary class]]) {
                [self constructTreeWithListing:[[[replies objectForKey:@"replies"] objectForKey:@"data" ] objectForKey:@"children"] atRoot:cm];
            }
            [root addChild: cm];
            
        }
    }
}



@end