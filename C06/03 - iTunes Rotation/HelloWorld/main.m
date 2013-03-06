/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

#import "SongDetailViewController.h"

@interface TestBedViewController : UITableViewController
{
    NSArray *items;
    NSString *searchTerm;
}
@end

@implementation TestBedViewController
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

    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void) failedFetchingJSON
{
    // something
    [self.refreshControl endRefreshing];
}

- (void) loadItems: (NSString *) searchString
{
    NSString *fullSearch = [NSString stringWithFormat:@"https://itunes.apple.com/search?limit=20&sort=popular&term=%@", searchString];
    NSURL *url = [NSURL URLWithString:fullSearch];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (data)
            dispatch_async(dispatch_get_main_queue(), ^{[self processJSON:data];});
        else
        {
            NSLog(@"Error retrieving data: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{[self failedFetchingJSON];});
        }
    }];
}

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
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dict = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = @"";
    cell.textLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:14];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (dict)
        cell.textLabel.text = dict[@"trackName"];
    return cell;
}

// On selection, update the title and enable find/deselect
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongDetailViewController *sdvc = [SongDetailViewController controllerWithData:items[indexPath.row]];
    [self.navigationController pushViewController:sdvc animated:YES];
}

- (void) refresh
{
    [self.refreshControl beginRefreshing];
    [self loadItems:@"Nashville+Cast"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

- (void) loadView
{
    [super loadView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.backgroundColor = AQUA_COLOR;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
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