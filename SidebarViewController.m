#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "ListViewController.h"
#import "Redditor/RedditAPIConnector.h"

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

    menuItems = @[@"s_bar",@"settings",@"account",@"title",@"front_head", @"pics", @"funny", @"gaming", @"askreddit", @"worldnews",@"news"];
    
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
    ListViewController* dest = (ListViewController*) destViewController;
    //dest.needRefresh = YES;
    if ([[segue identifier] isEqualToString:@"front_all_random_segue"]) {
        NSInteger index = [(UISegmentedControl*)sender selectedSegmentIndex];
        if (index == 0) {
            dest.sub = @"";
            destViewController.title = @"Front Page";
        }
        else if (index == 1 ) {
            dest.sub = @"all";
            destViewController.title = @"All";
        }
        else {
            /* random page */
            NSString* sub = [RedditAPIConnector getRedirect:[NSURL URLWithString:@"http://www.reddit.com/r/random"]];
            NSRange rangeOfSubstring = [sub rangeOfString:@"http://www.reddit.com/r/"];
            sub = [sub stringByReplacingCharactersInRange:rangeOfSubstring withString:@""];
            sub = [sub substringToIndex:[sub length] - 1];
            dest.sub = sub;
            destViewController.title = sub;
        }
       
    }
    else {
        dest.sub = [menuItems objectAtIndex:indexPath.row];
    }
    /*
    // Set the photo if it navigates to the PhotoView
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        ListViewController *listViewController = (ListViewController*)segue.destinationViewController;
        NSString *photoFilename = [NSString stringWithFormat:@"%@_photo.jpg", [menuItems objectAtIndex:indexPath.row]];
        listViewController.photoFilename = photoFilename;
    }
    */
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
}

@end
