//
//  SearchListViewController.m
//  Redditor
//
//  Created by Eddie Lau on 4/29/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import "SearchListViewController.h"
#import "SWRevealViewController.h"
#import "RedditorEngine.h"
#import "SVPullToRefresh.h"
#import "RedditPost.h"
#import "PostViewController.h"
#import "LinkViewController.h"
#import "RedditAPIConnector.h"

@interface SearchListViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property NSMutableArray* post;
@end

@implementation SearchListViewController {
}
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
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    self.revealViewController.delegate = self;
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.indicator.center = self.view.center;
    [self.indicator setHidesWhenStopped:YES];
    [self.view addSubview:self.indicator];
    [self.indicator startAnimating];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    self.post = [[NSMutableArray alloc] init];
    self.post = (NSMutableArray*)[eng searchPostsWithKeyword:[self searchString] InSubReddit:@"" After: @""];
     
    [[self tableView] setFrame:[self.scrollView bounds]];
    [self.scrollView addSubview:[self tableView]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width , self.scrollView.frame.size.height);
    
    __weak typeof(self) weakSelf = self; // weak self to prevent retain cycle
    
    [self.tableView addPullToRefreshWithActionHandler:^ {
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        RedditorEngine* eng = [[RedditorEngine alloc] init];
        weakSelf.post = (NSMutableArray*)[eng searchPostsWithKeyword:weakSelf.searchString InSubReddit:@"" After:@""];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.pullToRefreshView stopAnimating];
        });
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^ {
        RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
        RedditorEngine* eng = [[RedditorEngine alloc] init];
        [weakSelf.post addObjectsFromArray: [eng searchPostsWithKeyword:weakSelf.searchString InSubReddit:@"" After:lastPost.name]];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
    }];
        
        [self.tableView reloadData];
        [self.indicator stopAnimating];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.post count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier =@"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil || indexPath.row >= [self.post count]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        return cell;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    RedditPost* postToPrint = [self.post objectAtIndex:indexPath.row];
    
    /* add num of comments */
    UIButton* num_comments = [[UIButton alloc] init];
    
    [num_comments setTitle: [NSString stringWithFormat:@"%ld", postToPrint.num_comments] forState:UIControlStateNormal];
    [num_comments setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    num_comments.titleLabel.textAlignment= NSTextAlignmentCenter;
    num_comments.frame = CGRectMake(cell.accessoryView.frame.origin.x, cell.accessoryView.frame.origin.y, 40, 25);
    num_comments.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    num_comments.layer.borderWidth = 1.0;
    num_comments.layer.cornerRadius = 5;
    [num_comments.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    cell.accessoryView = num_comments;
    
    /* add click event to button */
    [num_comments addTarget: self
                     action: @selector(accessoryButtonTapped:withEvent:)
           forControlEvents: UIControlEventTouchUpInside];
    
    /* add content */
    NSString* cellText = [[self.post objectAtIndex:indexPath.row] title ];
    cell.textLabel.text= cellText;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    
    /* add the post info */
    [[cell viewWithTag:3] removeFromSuperview];
    UITextField* info = [[UITextField alloc] init];
    [info setEnabled:NO];
    NSString* infoString = [NSString stringWithFormat:@"Ups: %ld Downs: %ld", (long)postToPrint.ups, postToPrint.downs];
    info.text = infoString;
    info.tag = 3;
    info.textColor = [UIColor grayColor];
    info.translatesAutoresizingMaskIntoConstraints = NO;
    [info setFont:[UIFont systemFontOfSize:13.0]];
    [cell.contentView addSubview:info];
    
    //[cell addConstraint:[NSLayoutConstraint constraintWithItem:info attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
    
    //[cell addConstraint:[NSLayoutConstraint constraintWithItem:info attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:20]];
    
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:info attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-2]];
    
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:info attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    
    cell.imageView.image = nil;
    /* get the thumbnail */
    if (!([postToPrint.thumbnail isEqualToString:@""] || [postToPrint.thumbnail isEqualToString:@"self"])) {
        //NSLog(postToPrint.thumbnail);
        
        NSData* data = [RedditAPIConnector makeGetRequestTo:[NSURL URLWithString:postToPrint.thumbnail]];
        UIImage* thumbnail = [UIImage imageWithData:data];
        cell.imageView.image = thumbnail;
        
        //[cell addConstraint:[NSLayoutConstraint constraintWithItem:tnView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:-5]];
    }
    
    /* mark nsfw */
    if ([[postToPrint over_18] boolValue]) {
        cell.textLabel.textColor = [UIColor redColor];
    }

    
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    if (indexPath.row >= [self.post count]) {
        return 44;
    }
    NSString* cellText = [[self.post objectAtIndex:indexPath.row] title];
    
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
     */
    return 90;
}

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //Value Selected by user
    RedditPost *selectedPost = [self.post objectAtIndex:indexPath.row];
    //Initialize new viewController
    
    //PostViewController *viewController = [[PostViewController alloc] initWithNibName:@"PostViewController" bundle:nil];
    UIStoryboard *sb = self.storyboard;
    PostViewController *viewController = [sb instantiateViewControllerWithIdentifier:@"PostViewController"];
    //[sb ]
    [viewController setPost: selectedPost];
    //Pass selected value to a property declared in NewViewController
    
    //viewController.valueToPrint = selectedValue;
    //Push new view to navigationController stack
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Value Selected by user
    RedditPost *selectedPost = [self.post objectAtIndex:indexPath.row];
    //Initialize new viewController
    
    //PostViewController *viewController = [[PostViewController alloc] initWithNibName:@"PostViewController" bundle:nil];
    UIStoryboard *sb = self.storyboard;
    if (!selectedPost.is_self.boolValue) {
        LinkViewController *viewController = [sb instantiateViewControllerWithIdentifier:@"LinkViewController"];
        //[sb ]
        [viewController setUrl: selectedPost.url];
        //Pass selected value to a property declared in NewViewController
        viewController.title = selectedPost.title;
        //viewController.valueToPrint = selectedValue;
        //Push new view to navigationController stack
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        PostViewController *viewController = [sb instantiateViewControllerWithIdentifier:@"PostViewController"];
        //[sb ]
        [viewController setPost: selectedPost];
        //Pass selected value to a property declared in NewViewController
        
        //viewController.valueToPrint = selectedValue;
        //Push new view to navigationController stack
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

/* a custom accessory view won't trigger accessoryButonTappedForRowWithIndexPath on its own, so we need call it manually */
- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}


/*
 // Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        self.tableView.userInteractionEnabled = YES;
    } else {
        self.tableView.userInteractionEnabled = NO;
    }
}

@end
