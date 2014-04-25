#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) NSString *photoFilename;
@property BOOL needRefresh;
@property NSString* sub;
@end
