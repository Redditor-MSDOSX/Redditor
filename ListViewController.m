#import "ListViewController.h"
#import "SWRevealViewController.h"
#import "RedditorEngine.h"
#import "SVPullToRefresh.h"
#import "PostViewController.h"
#import "RedditAPIConnector.h"
#import "LinkViewController.h"
#import "AddLinkViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ListViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *controversialTable;
@property (strong, nonatomic) IBOutlet UITableView *theNewTable;
@property (strong, nonatomic) IBOutlet UITableView *hotTable;
@property (strong, nonatomic) IBOutlet UITableView *risingTable;
@property (strong, nonatomic) IBOutlet UITableView *topTable;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bar;
@end

@implementation ListViewController:UIViewController {
    NSInteger prevPage;
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
    prevPage = 0;
    self.current = self.hotTable;
    
    // Change button color
    //_sidebarButton.tintColor = [UIColor colorWithWhite:0.1f alpha:0.9f];

    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.revealViewController.delegate = self;
    self.indicator.center = self.view.center;
    [self.indicator setHidesWhenStopped:YES];
    [self.view addSubview:self.indicator];
    [self.indicator startAnimating];
    
    
    //self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 300)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    //[self.view addSubview:self.scrollView];
    if (!self.displayAddButton) {
        [self.addButton removeFromSuperview];
    }
    /* configure the buttons */
    self.addButton.enabled = NO;
    if (self.isRandom) {
        self.shuffleButton.enabled = NO;
    }
    else {
        [self.shuffleButton removeFromSuperview];
    }
    
    self.post = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *viewArray = [NSArray arrayWithObjects: self.hotTable, self.theNewTable, self.risingTable, self.controversialTable, self.topTable, nil];
        
        for(int i=0; i<viewArray.count; i++)
        {
            CGRect frame;
            frame.origin.x = self.scrollView.frame.size.width * i;
            frame.origin.y = 0;
            frame.size = self.scrollView.frame.size;
            
            [[viewArray objectAtIndex:i] setFrame: frame];
            [self.scrollView addSubview:[viewArray objectAtIndex:i]];
        }
        
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * viewArray.count, self.scrollView.frame.size.height);
        
        
        __weak typeof(self) weakSelf = self; // weak self to prevent retain cycle
        
        /* adding pull to refresh to tables */
        [self.hotTable addPullToRefreshWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [weakSelf loadContent];
                    [weakSelf.hotTable reloadData];
                    [weakSelf.hotTable.pullToRefreshView stopAnimating];
                });
            }
            else {
                [weakSelf.hotTable.pullToRefreshView stopAnimating];
            }
        }];
        [self.theNewTable addPullToRefreshWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [weakSelf loadContent];
                    [weakSelf.theNewTable reloadData];
                    [weakSelf.theNewTable.pullToRefreshView stopAnimating];
                });
            }
            else {
                [weakSelf.theNewTable.pullToRefreshView stopAnimating];
            }
        }];
        [self.controversialTable addPullToRefreshWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [weakSelf loadContent];
                    [weakSelf.controversialTable reloadData];
                    [weakSelf.controversialTable.pullToRefreshView stopAnimating];
                });
            }
            else {
                [weakSelf.controversialTable.pullToRefreshView stopAnimating];
            }
        }];
        [self.risingTable addPullToRefreshWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [weakSelf loadContent];
                    [weakSelf.risingTable reloadData];
                    [weakSelf.risingTable.pullToRefreshView stopAnimating];
                });
            }
            else {
                [weakSelf.risingTable.pullToRefreshView stopAnimating];
            }
        }];
        [self.topTable addPullToRefreshWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [weakSelf loadContent];
                    [weakSelf.topTable reloadData];
                    [weakSelf.topTable.pullToRefreshView stopAnimating];
                });
            }
            else {
                [weakSelf.topTable.pullToRefreshView stopAnimating];
            }
        }];
        
        /* adding infinite scrolling to tables */
        [self.hotTable addInfiniteScrollingWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
                [weakSelf extendContentAfter:lastPost.name];
                [weakSelf.hotTable reloadData];
                [weakSelf.hotTable.infiniteScrollingView stopAnimating];
            }
            else {
                [weakSelf.hotTable.infiniteScrollingView stopAnimating];
            }
        }];
        [self.theNewTable addInfiniteScrollingWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
                [weakSelf extendContentAfter:lastPost.name];
                [weakSelf.theNewTable reloadData];
                [weakSelf.theNewTable.infiniteScrollingView stopAnimating];
            }
            else {
                [weakSelf.theNewTable.infiniteScrollingView stopAnimating];
            }
        }];
        [self.risingTable addInfiniteScrollingWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
                [weakSelf extendContentAfter:lastPost.name];
                [weakSelf.risingTable reloadData];
                [weakSelf.risingTable.infiniteScrollingView stopAnimating];
            }
            else {
                [weakSelf.risingTable.infiniteScrollingView stopAnimating];
            }
        }];
        [self.controversialTable addInfiniteScrollingWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
                [weakSelf extendContentAfter:lastPost.name];
                [weakSelf.controversialTable reloadData];
                [weakSelf.controversialTable.infiniteScrollingView stopAnimating];
            }
            else {
                [weakSelf.controversialTable.infiniteScrollingView stopAnimating];
            }
        }];
        [self.topTable addInfiniteScrollingWithActionHandler:^{
            if ([weakSelf.post count] > 0) {
                RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
                [weakSelf extendContentAfter:lastPost.name];
                [weakSelf.topTable reloadData];
                [weakSelf.topTable.infiniteScrollingView stopAnimating];
            }
            else {
                [weakSelf.topTable.infiniteScrollingView stopAnimating];
            }
        }];
        
        if (self.isRandom) {
            NSString* sub = [RedditAPIConnector getRedirect:[NSURL URLWithString:@"http://www.reddit.com/r/random"]];
            NSRange rangeOfSubstring = [sub rangeOfString:@"http://www.reddit.com/r/"];
            sub = [sub stringByReplacingCharactersInRange:rangeOfSubstring withString:@""];
            sub = [sub substringToIndex:[sub length] - 1];
            self.sub = sub;
            self.title = sub;
        }
        
        
        [self loadContent];
        [self.hotTable reloadData];
        self.addButton.enabled = YES;
        self.shuffleButton.enabled = YES;
        [self.indicator stopAnimating];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadContent {
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    //NSArray* rawContent = [eng retrieveHotRedditPostsFromSubReddit:self.sub]; // default is hot
    self.post = [[NSMutableArray alloc] init];
    NSInteger page = [self.bar selectedSegmentIndex];
    if (page == 0) {
        self.post = (NSMutableArray*)[eng retrieveHotRedditPostsFromSubReddit:self.sub]; // default is hot
    }
    else if(page == 1) {
        self.post = (NSMutableArray*)[eng retrieveNewRedditPostsFromSubReddit:self.sub];
    }
    else if(page == 2) {
        self.post = (NSMutableArray*)[eng retrieveRisingRedditPostsFromSubReddit:self.sub];
    }
    else if(page == 3) {
        self.post = (NSMutableArray*)[eng retrieveControversialRedditPostsFromSubReddit:self.sub];
    }
    else if(page == 4) {
        self.post = (NSMutableArray*)[eng retrieveTopRedditPostsFromSubReddit:self.sub];
    }
    else {
        self.post = (NSMutableArray*)[eng retrieveHotRedditPostsFromSubReddit:self.sub]; // default is hot
    }
    
}

-(void) extendContentAfter: (NSString*) name {
    RedditorEngine* eng = [[RedditorEngine alloc] init];
    //NSArray* rawContent = [eng retrieveHotRedditPostsFromSubReddit:self.sub]; // default is hot
    if (self.post == nil) {
        self.post = [[NSMutableArray alloc] init];
    }
    NSInteger page = [self.bar selectedSegmentIndex];
    if (page == 0) {
        [self.post addObjectsFromArray:[eng retrieveHotRedditPostsFromSubReddit:self.sub After:name]]; // default is hot
    }
    else if(page == 1) {
        [self.post addObjectsFromArray: [eng retrieveNewRedditPostsFromSubReddit:self.sub After:name]];
    }
    else if(page == 2) {
        [self.post addObjectsFromArray: [eng retrieveRisingRedditPostsFromSubReddit:self.sub After:name]];
    }
    else if(page == 3) {
        [self.post addObjectsFromArray:[eng retrieveControversialRedditPostsFromSubReddit:self.sub After:name]];
    }
    else if(page == 4) {
        [self.post addObjectsFromArray:[eng retrieveTopRedditPostsFromSubReddit:self.sub After:name]];
    }
    else {
        [self.post addObjectsFromArray:[eng retrieveHotRedditPostsFromSubReddit:self.sub After:name]]; // default is hot
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog([NSString stringWithFormat: @"%d",[self.post count]]);
    return [self.post count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil || indexPath.row >= [self.post count] || indexPath.row < 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        return cell;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    //[cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    RedditPost* postToPrint = [self.post objectAtIndex:indexPath.row];
    
    /* update the accessory view */
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
    
    /* update the textlabel */
    NSString* cellText = [postToPrint title];
    cell.textLabel.text= cellText;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    
    /* add the post info */
    [[cell viewWithTag:3] removeFromSuperview];
    UITextField* info = [[UITextField alloc] init];
    [info setEnabled:NO];
    NSString* infoString = [NSString stringWithFormat:@"(%@)\u2191%ld\u2193%ld",postToPrint.author, (long)postToPrint.ups, postToPrint.downs];
    info.text = infoString;
    info.tag = 3;
    info.textColor = [UIColor grayColor];
    info.translatesAutoresizingMaskIntoConstraints = NO;
    [info setFont:[UIFont systemFontOfSize:11.0]];
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
    
    /* mark cell nsfw */
    if ([[postToPrint over_18] boolValue]) {
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (IBAction)tabChanged:(id)sender {
    // load the content
    
    [self.indicator startAnimating];
    //NSLog(@"Run");
    // update the list
    NSInteger page = [self.bar selectedSegmentIndex];
    prevPage = page;
    /* scroll to that page */
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    
    [self.scrollView scrollRectToVisible:frame animated:YES];
    if (page == 0) {
        [self.hotTable setAlpha:.1];
        self.current = self.hotTable;
    }
    else if(page == 1) {
        [self.theNewTable setAlpha:.1];
        self.current = self.theNewTable;
    }
    else if(page == 2) {
        [self.risingTable setAlpha:.1];
        self.current = self.risingTable;
    }
    else if(page == 3) {
        [self.controversialTable setAlpha:.1];
        self.current = self.controversialTable;
    }
    else if(page == 4) {
        [self.topTable setAlpha:.1];
        self.current = self.topTable;
    }
    
    
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self loadContent];
        if (page == 0) {
            [self.hotTable reloadData];
            [self.hotTable setAlpha:1];
        }
        else if(page == 1) {
            [self.theNewTable reloadData];
            [self.theNewTable setAlpha:1];
        }
        else if(page == 2) {
            [self.risingTable reloadData];
            [self.risingTable setAlpha:1];
        }
        else if(page == 3) {
            [self.controversialTable reloadData];
            [self.controversialTable setAlpha:1];
        }
        else if(page == 4) {
            [self.topTable reloadData];
            [self.topTable setAlpha:1];
        }
        
        
        [self.indicator stopAnimating];
    });
    
    
    //[self.pageControl setCurrentPage:page];
    
    
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //NSLog([scrollView.class description]);
    if (scrollView.class != UIScrollView.class) {
        return;
    }
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (page == prevPage) {
        return;
    }
    [self.indicator startAnimating];
    //[self.pageControl setCurrentPage:page];
    [self.bar setSelectedSegmentIndex:page]; // set this won't trigger tabChanged
    
    //[self.post removeAllObjects];
    if (page == 0) {
        [self.hotTable setAlpha:.1];
        self.current = self.hotTable;
    }
    else if(page == 1) {
        [self.theNewTable setAlpha:.1];
        self.current = self.theNewTable;
    }
    else if(page == 2) {
        [self.risingTable setAlpha:.1];
        self.current = self.risingTable;
    }
    else if(page == 3) {
        [self.controversialTable setAlpha:.1];
        self.current = self.controversialTable;
    }
    else if(page == 4) {
        [self.topTable setAlpha:.1];
        self.current = self.topTable;
    }
    prevPage = page;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadContent];
        //NSLog(@"Run");
        // update the list
        //NSInteger page = [self.bar selectedSegmentIndex];
        if (page == 0) {
            [self.hotTable reloadData];
            [self.hotTable setAlpha:1];
        }
        else if(page == 1) {
            [self.theNewTable reloadData];
            [self.theNewTable setAlpha:1];
        }
        else if(page == 2) {
            [self.risingTable reloadData];
            [self.risingTable setAlpha:1];
        }
        else if(page == 3) {
            [self.controversialTable reloadData];
            [self.controversialTable setAlpha:1];
        }
        else if(page == 4) {
            [self.topTable reloadData];
            [self.topTable setAlpha:1];
        }
        [self.indicator stopAnimating];
    });
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Value Selected by user
    RedditPost *selectedPost = [self.post objectAtIndex:indexPath.row];
    //Initialize new viewController
    
    //PostViewController *viewController = [[PostViewController alloc] initWithNibName:@"PostViewController" bundle:nil];
    UIStoryboard *sb = self.storyboard;
    if (!selectedPost.is_self.boolValue) {
        LinkViewController *viewController = [sb instantiateViewControllerWithIdentifier:@"LinkViewController"];
        //[sb ]
        [viewController setUrl: selectedPost.url];
        viewController.title = selectedPost.title;
        //Pass selected value to a property declared in NewViewController
        
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"add_segue"]) {
        AddLinkViewController* destViewController = (AddLinkViewController*)segue.destinationViewController;
        destViewController.sub = self.sub;
    }
}

/* a custom accessory view won't trigger accessoryButonTappedForRowWithIndexPath on its own, so we need call it manually */
- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSInteger page = [self.bar selectedSegmentIndex];
    if (page == 0) {
        NSIndexPath * indexPath = [self.hotTable indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.hotTable]];
        if ( indexPath == nil )
            return;
        
        [self.hotTable.delegate tableView: self.hotTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
    else if (page == 1) {
        NSIndexPath * indexPath = [self.theNewTable indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.theNewTable]];
        if ( indexPath == nil )
            return;
        
        [self.theNewTable.delegate tableView: self.theNewTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
    else if (page == 2) {
        NSIndexPath * indexPath = [self.risingTable indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.risingTable]];
        if ( indexPath == nil )
            return;
        
        [self.risingTable.delegate tableView: self.risingTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
    else if (page == 3) {
        NSIndexPath * indexPath = [self.controversialTable indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.controversialTable]];
        if ( indexPath == nil )
            return;
        
        [self.controversialTable.delegate tableView: self.controversialTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
    else if (page == 4) {
        NSIndexPath * indexPath = [self.topTable indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.topTable]];
        if ( indexPath == nil )
            return;
        
        [self.topTable.delegate tableView: self.topTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}
- (IBAction)shuffleButtonClicked:(id)sender {
    [self.indicator startAnimating];
    self.shuffleButton.enabled = NO;
    self.addButton.enabled = NO;
    self.title = @"";
    NSInteger page = self.bar.selectedSegmentIndex;
    if (page == 0) {
        [self.hotTable setAlpha:.1];
    }
    else if(page == 1) {
        [self.theNewTable setAlpha:.1];
    }
    else if(page == 2) {
        [self.risingTable setAlpha:.1];
    }
    else if(page == 3) {
        [self.controversialTable setAlpha:.1];
    }
    else if(page == 4) {
        [self.topTable setAlpha:.1];
    }
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.isRandom) {
            NSString* sub = [RedditAPIConnector getRedirect:[NSURL URLWithString:@"http://www.reddit.com/r/random"]];
            NSRange rangeOfSubstring = [sub rangeOfString:@"http://www.reddit.com/r/"];
            sub = [sub stringByReplacingCharactersInRange:rangeOfSubstring withString:@""];
            sub = [sub substringToIndex:[sub length] - 1];
            self.sub = sub;
            self.title = sub;
        }
        [self loadContent];
        if (page == 0) {
            [self.hotTable reloadData];
            [self.hotTable setAlpha:1];
        }
        else if(page == 1) {
            [self.theNewTable reloadData];
            [self.theNewTable setAlpha:1];
        }
        else if(page == 2) {
            [self.risingTable reloadData];
            [self.risingTable setAlpha:1];
        }
        else if(page == 3) {
            [self.controversialTable reloadData];
            [self.controversialTable setAlpha:1];
        }
        else if(page == 4) {
            [self.topTable reloadData];
            [self.topTable setAlpha:1];
        }
        self.shuffleButton.enabled = YES;
        self.addButton.enabled = YES;
        [self.indicator stopAnimating];
    });
    
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        self.current.userInteractionEnabled = YES;
        self.scrollView.userInteractionEnabled = YES;
        self.bar.userInteractionEnabled = YES;
    } else {
        self.current.userInteractionEnabled = NO;
        self.scrollView.userInteractionEnabled = NO;
        self.bar.userInteractionEnabled = NO;
    }
}
@end
