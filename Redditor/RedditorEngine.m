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

/*
 try to log in user
 returns Yes/No (sucessful or not)
 */
-(BOOL) loginWithUsername:(NSString *)name andPassword:(NSString *)pwd {
    NSData* data = nil;
    if ([name isEqualToString:@""] || [pwd isEqualToString:@""]) {
        return NO;
    }
    NSMutableDictionary* postData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* header = [[NSMutableDictionary alloc] init];
    [postData setObject:name forKey:@"user"];
    [postData setObject:pwd forKey:@"passwd"];
    [postData setObject:@"true" forKey:@"rem"];
    [postData setObject:@"json" forKey:@"api_type"];
    
    //NSInteger contentLength = [name length] + [pwd length] + 4 + 4 + 5 + 8 + 10 + 5;
    //[header setObject:[NSString stringWithFormat:@"%d", contentLength] forKey:@"Content-Length"];
    
    data = [RedditAPIConnector makePostRequestTo:[NSURL URLWithString:@"https://ssl.reddit.com/api/login"] WithData:[NSDictionary dictionaryWithDictionary:postData] andHeaders:[NSDictionary dictionaryWithDictionary:header] isLogin:YES];
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    
    if (error != nil) {
        NSLog(@"Error parsing JSON resonse or log in failed");
        return NO;
    }
    else {
        if ([json valueForKey:@"json"] == nil) {
            return NO;
        }
        json = [json objectForKey:@"json"];
        if ([[json objectForKey:@"errors" ] count] != 0) {
            return NO;
        }
        if ([json valueForKey:@"data"] == nil) {
            return NO;
        }
        if([[json objectForKey:@"data"] valueForKey:@"modhash"] == nil) {
            return NO;
        }
        return YES;
    }
}
-(BOOL) checkIfLoggedIn {
    NSString* modHash =[RedditAPIConnector getModhash];
    if (modHash != nil && ![modHash isEqualToString:@""]) {
        //NSLog(modHash);
        return YES;
    }
    return NO;
}

-(NSString*) getIdenForCaptcha {
    NSData* captcha;
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setObject:@"json" forKey:@"api_type"];
    NSDictionary* header = [[NSDictionary alloc] init];
    captcha = [RedditAPIConnector makePostRequestTo:[NSURL URLWithString:@"http://www.reddit.com/api/new_captcha"] WithData:data andHeaders:header isLogin:NO];
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:captcha options:kNilOptions error:&error];
    return [[[json objectForKey:@"json"] objectForKey:@"data"] objectForKey:@"iden"];
}

-(UIImage*) getCaptchaWithIden:(NSString *)iden {
    NSData* captcha = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/captcha/%@", iden]]];
    return [UIImage imageWithData:captcha];
}

@end