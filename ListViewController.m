#import "ListViewController.h"
#import "SWRevealViewController.h"
#import "RedditorEngine.h"
#import "SVPullToRefresh.h"

@interface ListViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *controversialTable;
@property (strong, nonatomic) IBOutlet UITableView *theNewTable;
@property (strong, nonatomic) IBOutlet UITableView *hotTable;
@property (strong, nonatomic) IBOutlet UITableView *risingTable;
@property (strong, nonatomic) IBOutlet UITableView *topTable;
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
    
    
    //self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 300)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    //[self.view addSubview:self.scrollView];
    
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
    [self loadContent];
    
    __weak typeof(self) weakSelf = self;
    
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
        self.post = [eng retrieveHotRedditPostsFromSubReddit:self.sub]; // default is hot
    }
    else if(page == 1) {
        self.post = [eng retrieveNewRedditPostsFromSubReddit:self.sub];
    }
    else if(page == 2) {
        self.post = [eng retrieveRisingRedditPostsFromSubReddit:self.sub];
    }
    else if(page == 3) {
        self.post = [eng retrieveControversialRedditPostsFromSubReddit:self.sub];
    }
    else if(page == 4) {
        self.post = [eng retrieveTopRedditPostsFromSubReddit:self.sub];
    }
    else {
        self.post = [eng retrieveHotRedditPostsFromSubReddit:self.sub]; // default is hot
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
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (IBAction)tabChanged:(id)sender {
    // load the content
    [self loadContent];
    //NSLog(@"Run");
    // update the list
    NSInteger page = [self.bar selectedSegmentIndex];
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
    
    /* scroll to that page */
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    //[self.pageControl setCurrentPage:page];
    
    
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != 0.0) {
        return;
    }
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    //[self.pageControl setCurrentPage:page];
    [self.bar setSelectedSegmentIndex:page]; // set this won't trigger tabChanged
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
    
}

@end
