/* RedditComment is a class that represents a comment and reference to all its children */

#import "RedditComment.h"

@implementation RedditComment

-(id) init {
    self = [super init];
    if (self != nil) {
        self.children = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) initWithDict:(NSDictionary *)dict {
    
    self = [super init];
    if (self!=nil) {
        //NSLog([dict objectForKey:@"ups"]);
        self.ups = [[dict objectForKey:@"ups"] intValue];
        self.downs = [[dict objectForKey:@"downs"] intValue];
        self.name = [dict objectForKey:@"name"];
        self.author = [dict objectForKey:@"author"];
        self.created_utc = [[dict objectForKey:@"created_utc"] intValue];
        self.children = [[NSMutableArray alloc] init];
        self.body = [dict objectForKey:@"body"];
    }
    return self;
    
}

-(void) addChild:(RedditComment *)comment {
    [self.children addObject:comment];
}


@end
