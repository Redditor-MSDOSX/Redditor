#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) NSString *photoFilename;
@property NSString* sub; // the subreddit
@property BOOL isRandom;
@property NSMutableArray* post; // the reddit posts
@property BOOL displayAddButton; // to hide add link button or not

-(NSInteger)numberOfSectionsInTableView: (UITableView *)tableView;

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

-(UITableViewCell *)tableView:(UITableView *)tableView cellforRowAtIndexPath:(NSIndexPath *)indexPath;

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end


