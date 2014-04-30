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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
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
    self.indicator.center = self.view.center;
    [self.indicator setHidesWhenStopped:YES];
    [self.view addSubview:self.indicator];
    [self.indicator startAnimating];
    
    //[self.view addSubview:activityView];
    
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

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    NSString* id = [[self.post name] substringFromIndex:3];
    //NSLog(id);
    RedditComment* commentTree = [eng retrieveCommentTreeFromArticle:id FocusAt:@""];
    self.comments = [[NSMutableArray alloc ] init];
    self.comments = [self commentsAry: commentTree Depth:0];
    [self.tableView reloadData];
    [self.indicator stopAnimating];
    
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
    return ([self.comments count] - 1)*2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil || indexPath.row >= ([self.comments count] - 1)*2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        return cell;
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.row % 2 == 0) {
        // author row
        NSString* cellText = [[self.comments objectAtIndex:(indexPath.row+1)/2 + 1] author ];
        cell.textLabel.text= cellText;
        cell.textLabel.textColor = [UIColor blueColor];
    }
    else {
        NSString* cellText = [[self.comments objectAtIndex:(indexPath.row+1) / 2] body ];
        cell.textLabel.text= cellText;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    /*
    cell.indentationWidth = 15.0;
    NSInteger indentLevel = [[self.comments objectAtIndex:indexPath.row+1] depth ] - 1;
    cell.indentationLevel = indentLevel;
     */
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];

    CGFloat lineIndent = 15.0;
    //NSLog(cellText);
    //NSLog([NSString stringWithFormat:@"%ld", (long)cell.indentationLevel ]);
    for (NSInteger i = 1; i <= cell.indentationLevel; i++) {
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(cell.bounds.origin.x + lineIndent * i + 3.0, cell.bounds.origin.y, 1, cell.bounds.size.height)];
        lineView.backgroundColor = [UIColor grayColor];
        //lineView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        [cell.contentView addSubview:lineView];
        //NSLog(@"Added");
    }
    //NSLog([NSString stringWithFormat:@"%f", cell.contentView.bounds.size.height ]);
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= ([self.comments count]-1)*2 || indexPath.row % 2 == 0) {
        return 24;
    }
    NSInteger row;
    if (indexPath.row % 2 == 0) {
        // author
        row = (indexPath.row + 1)/2 + 1;
    }
    else {
        row = (indexPath.row + 1)/2;
    }
    
    NSString* cellText = [[self.comments objectAtIndex:row] body];
    
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    NSInteger indentLevel = [[self.comments objectAtIndex:row] depth ] - 1;

    CGSize constraintSize = CGSizeMake(self.tableView.frame.size.width - 30 - indentLevel * 15.0, MAXFLOAT);
    //CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    //NSDictionary *attributes = @{NSFontAttributeName: cellFont, NSString.attributes.constrainedToSize: constraintSize, lineBreakMode:NSLineBreakByWordWrapping};
    
    CGRect textRect = [cellText boundingRectWithSize: constraintSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: cellFont}
                                             context:nil];
    
    CGSize labelSize = textRect.size;
    return labelSize.height + 10;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row;
    if (indexPath.row % 2 == 0) {
        // author
        row = (indexPath.row + 1)/2 + 1;
    }
    else {
        row = (indexPath.row + 1)/2;
    }
    
    
    NSInteger indentLevel = [[self.comments objectAtIndex:row] depth ] - 1;
    return indentLevel;
}


@end
