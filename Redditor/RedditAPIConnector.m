/*
 RedditAPIConnector is a class that makes HTTP request to the reddit API
*/

#import "RedditAPIConnector.h"

@implementation RedditAPIConnector

+(NSData*) makeGetRequestTo:(NSURL*) url {    
    /* initialize necessary instance */
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL: url];
    [request setTimeoutInterval:30];
    NSHTTPURLResponse* response = nil;
    NSError* error = [[NSError alloc] init];
    
    /* now make a request */
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    /* check the response */
    if ([response statusCode] != 200) {
        NSLog(@"Error %i", [response statusCode]);
        return [[NSData alloc] init];
    }
    return responseData;
}

@end
