//
//  LinkViewController.m
//  Redditor
//
//  Created by Eddie Lau on 5/3/14.
//  Copyright (c) 2014 Berkeley. All rights reserved.
//

#import "LinkViewController.h"

@interface LinkViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation LinkViewController {
    BOOL isFullscreen;
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
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.webView setFrame:self.view.frame];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    [self.view addSubview:self.webView];
    NSURL* nsUrl = [NSURL URLWithString:self.url];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    // For FullSCreen Entry
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeVideofullScreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    
    // For FullSCreen Exit
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeVideoExit:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    isFullscreen = NO;
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.webView reload];
}

-(void)viewDidDisappear:(BOOL)animated {
    if (!isFullscreen) {
        [super viewDidDisappear:animated];
        [self.webView loadHTMLString:@"" baseURL:nil];
    }
}


- (void)youTubeVideofullScreen:(id)sender
{   //Set Flag True.
    isFullscreen = YES;
    
}

- (void)youTubeVideoExit:(id)sender
{
    //Set Flag False.
    isFullscreen = NO;
}


-(void)viewWillDisappear:(BOOL)animated{
    //Just Check If Flag is TRUE Then Avoid The Execution of Code which Intrupting the Video Playing.
    if(!isFullscreen)
        //here avoid the thing which you want. genrally you were stopping the Video when you will leave the This Video view.
        [super viewWillDisappear:animated];
}

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
