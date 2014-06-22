#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "ListViewController.h"
#import "Redditor/RedditAPIConnector.h"
#import "Redditor/SearchListViewController.h"
#import "RedditorEngine.h"
#import "AccountViewController.h"

@interface SidebarViewController ()

@end

@implementation SidebarViewController {
    NSArray *menuItems;
    NSArray *ownSubs;
    BOOL searchBarClicked;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    menuItems = @[@"s_bar",@"settings",@"account",@"title",@"front_head", @"pics", @"funny", @"gaming", @"askreddit", @"worldnews",@"news", @"custom", @"ownsub"];
    
    ownSubs = [RedditorEngine getUserSubscribedSubReddit];
    [self.tableView reloadData];
    UIImageView* bgView = [[UIImageView alloc] init];
    [bgView setImage:[UIImage imageNamed:@"sibebar_bg.png"]];
    [self.tableView setBackgroundView: bgView];
    searchBarClicked = NO;
}

/*
- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"Appearing");
    
    [self.tableView reloadData];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [menuItems count] - 1;
    }
    else {
        return [ownSubs count];
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    }
    return @"Your Subscription";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    if (indexPath.section == 1) { // own subscription
        CellIdentifier = [menuItems objectAtIndex:12];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = [[ownSubs objectAtIndex:indexPath.row ] capitalizedString];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Light" size:20.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    else {
        CellIdentifier = [menuItems objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"search_segue"]) {
        searchBarClicked = NO;
        return YES;
    }
    else if (searchBarClicked == YES) {
        searchBarClicked = NO;
        return NO;
    }
    return YES;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    //destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    UIViewController* dest = (UIViewController*)destViewController;
    //dest.needRefresh = YES;
    if ([[segue identifier] isEqualToString:@"front_all_random_segue"]) {
        NSInteger index = [(UISegmentedControl*)sender selectedSegmentIndex];
        if (index == 0) {
            ((ListViewController*)dest).sub = @"";
            ((ListViewController*)dest).displayAddButton = NO;
            destViewController.title = @"Front Page";
        }
        else if (index == 1 ) {
            ((ListViewController*)dest).sub = @"all";
            ((ListViewController*)dest).displayAddButton = NO;
            destViewController.title = @"All";
        }
        else {
            /* random page */
            ((ListViewController*)dest).displayAddButton = YES;
            ((ListViewController*)destViewController).title = @"";
            ((ListViewController*)destViewController).isRandom = YES;
        }
        
       
    }
    else if ([[segue identifier] isEqualToString:@"search_segue"]){
        [((SearchListViewController*)dest) setSearchString:[(UISearchBar*)sender text]];
        destViewController.title = [(UISearchBar*)sender text];
        
    }
    else if ([[segue identifier] isEqualToString:@"custom_segue"]){
        UITextField* field = (UITextField*)[self.view viewWithTag:314]; // can't outlet textfield in prototype cell, use tag=314 instead
        ((ListViewController*)destViewController).title = field.text;
        [((ListViewController*)destViewController) setSub:field.text];
        ((ListViewController*)dest).displayAddButton = YES;
    }
    else if ([[segue identifier] isEqualToString:@"ownsub_segue"]){
        NSString* sub = ((UITableViewCell*)sender).textLabel.text;
        ((ListViewController*)destViewController).title = sub;
        [((ListViewController*)destViewController) setSub:[sub lowercaseString]]; // just lower case for precaution
        ((ListViewController*)dest).displayAddButton = YES;
    }
    else if ([[segue identifier] isEqualToString:@"account_segue"]){
        ((AccountViewController*)dest).delegate = self;
    }

    else if ([destViewController respondsToSelector:@selector(setSub:)]){
        ((ListViewController*)dest).title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
        [((ListViewController*)destViewController) setSub: [menuItems objectAtIndex:indexPath.row]];
        ((ListViewController*)dest).displayAddButton = YES;
    }
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar endEditing:YES];
    if (searchBar.tag == 313) {
        // search post
        searchBarClicked = NO;
        [self performSegueWithIdentifier:@"search_segue" sender:searchBar];
    }
    else if (searchBar.tag == 314) {
        // serach subreddit
        searchBarClicked = NO;
        [self performSegueWithIdentifier:@"custom_segue" sender:searchBar];
    }
    
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBarClicked = YES;
}


/* trying to hide keyboard */
- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.view viewWithTag:313] resignFirstResponder];
    [[self.view viewWithTag:314] resignFirstResponder];
    /*
    if (indexPath.row > 11) {
        [self performSegueWithIdentifier:@"ownsub_segue" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
     */
    //[self.view endEditing:YES];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [[self.view viewWithTag:313] resignFirstResponder];
    [[self.view viewWithTag:314] resignFirstResponder];
    if (searchBarClicked) {
        searchBarClicked = NO;
    }
    //[self.view endEditing:YES];
}

- (void) updateSubscription {
    ownSubs = [RedditorEngine getUserSubscribedSubReddit];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //[cell setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    //[UIColor colorWithPatternImage:[UIImage imageNamed:@"IMG_5649.JPG"]];

    
}

@end
