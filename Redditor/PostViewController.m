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
    //NSLog(id);
    RedditComment* commentTree = [eng retrieveCommentTreeFromArticle:id FocusAt:@""];
    self.comments = [[NSMutableArray alloc ] init];
    self.comments = [self commentsAry: commentTree Depth:0];
}

- (NSArray*) commentsAry : (RedditComment*) treeIn Depth: (NSInteger) depth{
    NSMutableArray* cAry = [[NSMutableArray alloc] init];
    [treeIn setDepth: depth];
    [cAry addObject:treeIn];
    if (treeIn.children.count == 0) {
        return cAry;
    }
    
    for (RedditComment* child in treeIn.children) {
        [cAry addObjectsFromArray:[self commentsAry: child Depth: depth + 1]];
    }
    treeIn.children = nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.comments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil || indexPath.row >= [self.comments count]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        return cell;
    }
    NSString* cellText = [NSString stringWithFormat:@"%ld %@", indexPath.row + 1, [[self.comments objectAtIndex:indexPath.row] body ]];
    cell.textLabel.text= cellText;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.comments count]) {
        return 44;
    }
    NSString* cellText = [[self.comments objectAtIndex:indexPath.row] body];
    
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    //CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    //NSDictionary *attributes = @{NSFontAttributeName: cellFont, NSString.attributes.constrainedToSize: constraintSize, lineBreakMode:NSLineBreakByWordWrapping};
    
    CGRect textRect = [cellText boundingRectWithSize: constraintSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: cellFont}
                                             context:nil];
    
    CGSize labelSize = textRect.size;
    return labelSize.height + 10;
}


@end
