/*
 RedditAPIConnector is a class that makes HTTP request to the reddit API
*/

#import <Foundation/Foundation.h>

@interface RedditAPIConnector : NSObject

+(NSData*) makeGetRequestTo: (NSURL*) url;

@end

