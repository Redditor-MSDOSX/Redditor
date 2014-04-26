/*
 RedditAPIConnector is a class that makes HTTP request to the reddit API
*/

#import <Foundation/Foundation.h>

@interface RedditAPIConnector : NSObject

+(NSData*) makeGetRequestTo: (NSURL*) url;
+(NSData*) makePostRequestTo: (NSURL*) url WithData: (NSDictionary*) data andHeaders: (NSDictionary*) header isLogin: (BOOL) flag;
+(NSString*) getModhash;
+(NSString*) getRedirect: (NSURL*) url;
@end

