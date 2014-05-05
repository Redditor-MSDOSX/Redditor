#import "ListViewController.h"
#import "SWRevealViewController.h"
#import "RedditorEngine.h"
#import "SVPullToRefresh.h"
#import "PostViewController.h"
#import "RedditAPIConnector.h"
#import "LinkViewController.h"
#import "AddLinkViewController.h"

@interface ListViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *controversialTable;
@property (strong, nonatomic) IBOutlet UITableView *theNewTable;
@property (strong, nonatomic) IBOutlet UITableView *hotTable;
@property (strong, nonatomic) IBOutlet UITableView *risingTable;
@property (strong, nonatomic) IBOutlet UITableView *topTable;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bar;
@end

@implementation ListViewController:UIViewController

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
    self.addButton.enabled = NO;
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
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf loadContent];
                [weakSelf.hotTable reloadData];
                [weakSelf.hotTable.pullToRefreshView stopAnimating];
            });
        }];
        [self.theNewTable addPullToRefreshWithActionHandler:^{
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf loadContent];
                [weakSelf.theNewTable reloadData];
                [weakSelf.theNewTable.pullToRefreshView stopAnimating];
            });
        }];
        [self.controversialTable addPullToRefreshWithActionHandler:^{
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf loadContent];
                [weakSelf.controversialTable reloadData];
                [weakSelf.controversialTable.pullToRefreshView stopAnimating];
            });
        }];
        [self.risingTable addPullToRefreshWithActionHandler:^{
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf loadContent];
                [weakSelf.risingTable reloadData];
                [weakSelf.risingTable.pullToRefreshView stopAnimating];
            });
        }];
        [self.topTable addPullToRefreshWithActionHandler:^{
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf loadContent];
                [weakSelf.topTable reloadData];
                [weakSelf.topTable.pullToRefreshView stopAnimating];
            });
        }];
        
        /* adding infinite scrolling to tables */
        [self.hotTable addInfiniteScrollingWithActionHandler:^{
            RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
            [weakSelf extendContentAfter:lastPost.name];
            [weakSelf.hotTable reloadData];
            [weakSelf.hotTable.infiniteScrollingView stopAnimating];
        }];
        [self.theNewTable addInfiniteScrollingWithActionHandler:^{
            RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
            [weakSelf extendContentAfter:lastPost.name];
            [weakSelf.theNewTable reloadData];
            [weakSelf.theNewTable.infiniteScrollingView stopAnimating];
        }];
        [self.risingTable addInfiniteScrollingWithActionHandler:^{
            RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
            [weakSelf extendContentAfter:lastPost.name];
            [weakSelf.risingTable reloadData];
            [weakSelf.risingTable.infiniteScrollingView stopAnimating];
        }];
        [self.controversialTable addInfiniteScrollingWithActionHandler:^{
            RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
            [weakSelf extendContentAfter:lastPost.name];
            [weakSelf.controversialTable reloadData];
            [weakSelf.controversialTable.infiniteScrollingView stopAnimating];
        }];
        [self.topTable addInfiniteScrollingWithActionHandler:^{
            RedditPost* lastPost = [weakSelf.post objectAtIndex:([weakSelf.post count] - 1)];
            [weakSelf extendContentAfter:lastPost.name];
            [weakSelf.topTable reloadData];
            [weakSelf.topTable.infiniteScrollingView stopAnimating];
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
    if (cell == nil || indexPath.row >= [self.post count]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        return cell;
    }
    NSString* cellText = [[self.post objectAtIndex:indexPath.row] title];
    cell.textLabel.text= cellText;
    cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    
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
    return 70;
    
}
- (IBAction)tabChanged:(id)sender {
    // load the content
    
    
    //NSLog(@"Run");
    // update the list
    NSInteger page = [self.bar selectedSegmentIndex];
    /* scroll to that page */
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadContent];
        if (page == 0) {
            
            [self.hotTable reloadData];
        }
        else if(page == 1) {
            [self.theNewTable reloadData];
        }
        else if(page == 2) {
            [self.risingTable reloadData];
        }
        else if(page == 3) {
            [self.controversialTable reloadData];
        }
        else if(page == 4) {
            [self.topTable reloadData];
        }
    });
    
    
    //[self.pageControl setCurrentPage:page];
    
    
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != 0.0) {
        return;
    }
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    //[self.pageControl setCurrentPage:page];
    [self.bar setSelectedSegmentIndex:page]; // set this won't trigger tabChanged
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadContent];
        //NSLog(@"Run");
        // update the list
        //NSInteger page = [self.bar selectedSegmentIndex];
        if (page == 0) {
            [self.hotTable reloadData];
        }
        else if(page == 1) {
            [self.theNewTable reloadData];
        }
        else if(page == 2) {
            [self.risingTable reloadData];
        }
        else if(page == 3) {
            [self.controversialTable reloadData];
        }
        else if(page == 4) {
            [self.topTable reloadData];
        }
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

@end
