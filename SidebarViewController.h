
#import <UIKit/UIKit.h>

@interface SidebarViewController : UITableViewController <UISearchBarDelegate>

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void) updateSubscription;
@end
