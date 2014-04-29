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

@interface SearchListViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property NSMutableArray* post;
@end

@implementation SearchListViewController
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
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.1f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
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
    NSString* cellText = [NSString stringWithFormat:@"%ld %@", indexPath.row + 1, [[self.post objectAtIndex:indexPath.row] title ]];
    cell.textLabel.text= cellText;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

@end
