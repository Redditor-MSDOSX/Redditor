/*
 RedditorEngine is a class that provides service to access the Reddit API
 Includes:
 * retreiving hot posts from Reddit
 */

#import <Foundation/Foundation.h>
#import "RedditPost.h"
#import "RedditComment.h"

@interface RedditorEngine : NSObject

-(NSArray*) retrieveHotRedditPostsFromSubReddit: (NSString*) sub;
-(NSArray*) retrieveNewRedditPostsFromSubReddit: (NSString*) sub;
-(NSArray*) retrieveRisingRedditPostsFromSubReddit: (NSString*) sub;
-(NSArray*) retrieveControversialRedditPostsFromSubReddit: (NSString*) sub;
-(NSArray*) retrieveTopRedditPostsFromSubReddit: (NSString*) sub;

-(RedditPost*) retrieveCommentTreeFromArticle: (NSString*) id FocusAt: (NSString*) root;

-(BOOL) loginWithUsername: (NSString*) name andPassword: (NSString*) pwd;

-(void) logoutUser;

-(BOOL) checkIfLoggedIn;

-(NSString*) getIdenForCaptcha;

-(UIImage*) getCaptchaWithIden: (NSString*) iden;

-(NSArray*) searchPostsWithKeyword: (NSString*) keyword InSubReddit:(NSString *)sub;


@end

