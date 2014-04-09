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
-(NSArray*) retrieveHotRedditPostsFromSubReddit: (NSString*) sub{
    NSData* data = nil;
    if ([sub isEqualToString:@""]) {
        data = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString:@"http://www.reddit.com/hot.json"]];
    }
    else {
        data = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString: [NSString stringWithFormat:@"http://www.reddit.com/r/%@/hot.json", sub]]];
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