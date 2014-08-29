/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "Utility.h"
#import "CustomTableViewCell.h"


@interface TestBedViewController : UITableViewController
@end

@implementation TestBedViewController
{
    NSArray *items;
    NSMutableDictionary *imageDictionary;

    AVPlayer *player;
    NSTimer *playTimer;
    
    NSString *searchString;
}

#pragma mark - Memory
- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [imageDictionary removeAllObjects];
}

#pragma mark - Retrieving info from iTunes

- (void) processJSON: (NSData *) json
{
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    if (!dict)
    {
        NSLog(@"Error converting JSON data: %@", error.localizedDescription);
        return;
    }
    
    items = dict[@"results"];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void) failedFetchingJSON
{
    [self.refreshControl endRefreshing];
}

- (void) loadItems: (NSString *) theString
{
    NSString *fullSearch = [NSString stringWithFormat:@"https://itunes.apple.com/search?limit=20&sort=popular&term=%@", [theString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:fullSearch];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (data)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self processJSON:data];});
        }
        else
        {
            NSLog(@"Error retrieving data: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self failedFetchingJSON];});
        }
    }];
}

- (void) lazyLoadImage: (NSString *) urlString to: (UIImageView *) imageView;
{
    if (!urlString) return;
    if (!imageView) return;
    
    if (imageDictionary[urlString])
    {
        imageView.image = imageDictionary[urlString];
        return;
    }
    
    UIImageView __weak *weakView = imageView;

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (!data)
         {
             NSLog(@"Error retrieving image data from iTunes: %@", error.localizedDescription);
             return;
         }
         
         UIImage *image = [UIImage imageWithData:data];
         if (!image)
         {
             NSLog(@"Error converting image data into image");
             return;
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             imageDictionary[urlString] = image;
             weakView.image = image;
         });
     }];
}

#pragma mark - Load Data

// Reload data from iTunes
- (void) refresh
{
    [self stop];
    [self.refreshControl beginRefreshing];
    [self loadItems:searchString];
}

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
        return;
    
    NSString *string = [[alertView textFieldAtIndex:0] text];
    if (!string) return;
    if (!string.length) return;
    
    searchString = string;
    [self refresh];
}

- (void) search
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Phrase:" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setText:searchString];
    [[alertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeAlways];
    [alertView show];
}

#pragma mark - Playback

- (void) stop
{
    self.title = nil;
    
    NSArray *visibleItems = [self.tableView indexPathsForVisibleRows];
    if (playTimer && playTimer.userInfo && [visibleItems containsObject:playTimer.userInfo])
    {
        CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:playTimer.userInfo];
        cell.percent = 0;
    }
    
    if (playTimer)
    {
        [playTimer invalidate];
        playTimer = nil;
    }
    
    if (player)
    {
        [player pause];
        self.navigationItem.leftBarButtonItem = nil;
        player = nil;
    }
}

- (void) didFinishPlaying
{
    [self stop];
}

- (CGFloat) percentPlayed
{
    AVPlayerItem *item = player.currentItem;
    if (CMTIME_IS_INVALID(item.duration))
        return 0.0f;
    if (CMTIME_IS_INVALID(player.currentTime))
        return 0.0f;
    
    CGFloat duration = CMTimeGetSeconds(item.duration);
    CGFloat current = CMTimeGetSeconds(player.currentTime);
    
    return current / duration;
}

- (void) tick
{
    CGFloat progress = [self percentPlayed];

    NSArray *visibleItems = [self.tableView indexPathsForVisibleRows];
    if (playTimer && playTimer.userInfo && [visibleItems containsObject:playTimer.userInfo])
    {
        CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:playTimer.userInfo];
        cell.percent = progress;
    }

    if (progress > 0.999)
        [self stop];
}

#pragma mark - Table Delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self stop];
    self.title = nil;
    
    // Retrieve Cell
    UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
    if (!cell.nametag)
        return;
    
    // Create player
    NSError *error;
    NSURL *url = [NSURL URLWithString:cell.nametag];
    player = [AVPlayer playerWithURL:url];
    if (!player)
    {
        NSLog(@"Error establishing player: %@", error.localizedDescription);
        return;
    }
    
    // Prepare for playback
    self.title = cell.textLabel.text;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(tick) userInfo:indexPath repeats:YES];
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Stop", @selector(stop));
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:player];
    
    // Start playback
    [player play];
}

#pragma mark - Other

- (void) buy: (UIButton *) button
{
    // no op
}

#pragma mark - Data Source

// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dict = [items objectAtIndex:indexPath.row];

    // Track Name
    cell.textLabel.text = @"";
    if (dict)
        cell.textLabel.text = dict[@"trackName"];

    // Preview URL
    cell.nametag = nil;
    if (dict[@"previewUrl"])
        cell.nametag = dict[@"previewUrl"];

    // Album Art
    cell.imageView.image = nil;
    if (dict[@"artworkUrl60"])
        [self lazyLoadImage:dict[@"artworkUrl60"] to:cell.imageView];
    
    // Buy Button
    [cell.buyButton setTitle:nil forState:UIControlStateNormal];
    [cell.buyButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllTouchEvents];
    if (dict[@"trackPrice"])
    {
        NSNumber *number = dict[@"trackPrice"];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        NSString *buttonString = [formatter stringFromNumber:number];

        [cell.buyButton setTitle:buttonString forState:UIControlStateNormal];
        [cell.buyButton addTarget:self action:@selector(buy:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Set play timer
    cell.percent = 0.0f;
    NSIndexPath *playPath = playTimer.userInfo;
    if (playPath && ([playPath compare:indexPath] == NSOrderedSame))
        cell.percent = [self percentPlayed];

    return cell;
}

#pragma mark - View Loading

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

- (void) loadView
{
    [super loadView];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Search", @selector(search));
    
    // Register cell
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    // Table details
    self.tableView.rowHeight = 100;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    imageDictionary = [NSMutableDictionary dictionary];
    
    searchString = @"Blake Shelton";
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic) UIWindow *window;
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    srandom(time(0));
    [[UINavigationBar appearance] setTintColor:ORANGE_COLOR];

	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    _window.rootViewController = nav;
	[_window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}