#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "ListViewController.h"
#import "Redditor/RedditAPIConnector.h"
#import "Redditor/SearchListViewController.h"

@interface SidebarViewController ()

@end

@implementation SidebarViewController {
    NSArray *menuItems;
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

    menuItems = @[@"s_bar",@"settings",@"account",@"title",@"front_head", @"pics", @"funny", @"gaming", @"askreddit", @"worldnews",@"news",@"custom"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    UIViewController* dest = (UIViewController*)destViewController;
    //dest.needRefresh = YES;
    if ([[segue identifier] isEqualToString:@"front_all_random_segue"]) {
        NSInteger index = [(UISegmentedControl*)sender selectedSegmentIndex];
        if (index == 0) {
            ((ListViewController*)dest).sub = @"";
            destViewController.title = @"Front Page";
        }
        else if (index == 1 ) {
            ((ListViewController*)dest).sub = @"all";
            destViewController.title = @"All";
        }
        else {
            /* random page */
            
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
    }
    else if ([destViewController respondsToSelector:@selector(setSub:)]){
        [((ListViewController*)destViewController) setSub: [menuItems objectAtIndex:indexPath.row]];
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
        [self performSegueWithIdentifier:@"search_segue" sender:searchBar];
    }
    else if (searchBar.tag == 314) {
        // serach subreddit
        [self performSegueWithIdentifier:@"custom_segue" sender:searchBar];
    }
    
}




/* trying to hide keyboard */
- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.view viewWithTag:313] resignFirstResponder];
    [[self.view viewWithTag:314] resignFirstResponder];
    //[self.view endEditing:YES];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [[self.view viewWithTag:313] resignFirstResponder];
    [[self.view viewWithTag:314] resignFirstResponder];
    //[self.view endEditing:YES];
}

@end
