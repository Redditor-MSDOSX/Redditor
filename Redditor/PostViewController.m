//
//  PostViewController.m
//  Redditor
//
//  Created by Kevin Qi on 4/29/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import "PostViewController.h"
#import "RedditorEngine.h"

@interface PostViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray* comments;
@end

@implementation PostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [self.post title];
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    NSString* id = [[self.post name] substringFromIndex:3];
    NSLog(id);
    RedditComment* commentTree = [eng retrieveCommentTreeFromArticle:id FocusAt:@""];
    self.comments = [self commentsAry: commentTree Depth:0];
    for (RedditComment* comment in self.comments) {
        NSLog(comment.body);
    }
}

- (NSArray*) commentsAry : (RedditComment*) treeIn Depth: (NSInteger) depth{
    NSMutableArray* cAry = [[NSMutableArray alloc] init];
    [treeIn setDepth: depth];
    [cAry addObject:treeIn];
    if (treeIn.children.count == 0) {
        return [[NSArray alloc] init];
    }
    
    for (RedditComment* child in treeIn.children) {
        [cAry addObjectsFromArray:[self commentsAry: child Depth: depth + 1]];
    }
    return cAry;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
