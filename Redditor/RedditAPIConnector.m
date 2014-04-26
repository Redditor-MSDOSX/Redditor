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
        NSLog(@"Error %li", (long)[response statusCode]);
        return [[NSData alloc] init];
    }
    return responseData;
}

+(NSData*) makePostRequestTo:(NSURL *)url WithData:(NSDictionary *)data andHeaders:(NSDictionary *)header isLogin:(BOOL)flag{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL: url];
    NSMutableString* formData = [NSMutableString stringWithString:@""];
    for (NSString* key in [data allKeys]) {
        [formData appendFormat:@"%@=%@&", key, [data objectForKey:key]];
    }
    [formData deleteCharactersInRange:NSMakeRange(([formData length] - 1), 1)];
    [request setHTTPBody:[formData dataUsingEncoding:NSUTF8StringEncoding]];
    
    for (NSString* key in [header allKeys]) {
        [request addValue:[header objectForKey:key] forHTTPHeaderField:key];
    }
    [request setTimeoutInterval:30];
    
    if (flag) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookiesForURL: url];
        for (NSHTTPCookie *cookie in cookies) {
            NSLog(@"Deleting cookie for domain: %@", [cookie domain]);
            [cookieStorage deleteCookie:cookie];
        }
    }
    //[request addValue: [NSString stringWithFormat:@"%d",[[NSKeyedArchiver archivedDataWithRootObject:data] length]] forHTTPHeaderField:@"Content-Length"] ;
    NSHTTPURLResponse* response = nil;
    NSError* error = [[NSError alloc] init];
    
    /* now make a POST request */
    //[request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    /* check the response */
    if ([response statusCode] != 200) {
        NSLog(@"Error %li", (long)[response statusCode]);
        return [[NSData alloc] init];
    }
    return responseData;
}

+(NSString*) getModhash {
    NSData* data = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString:@"http://www.reddit.com/api/me.json"]];
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return [[json objectForKey:@"data"] objectForKey:@"modhash"];
}

+(NSString*) getRedirect:(NSURL *)url {
    NSData *data=nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSURLResponse *response;
    NSError *error;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSURL *lastURL=[response URL];
    return [lastURL absoluteString];
}


@end
