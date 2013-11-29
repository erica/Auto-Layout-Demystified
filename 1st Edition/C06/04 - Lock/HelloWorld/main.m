/*
 
 Erica Sadun, http://ericasadun.com

 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

#import "LockControl.h"

@interface TestBedViewController : UIViewController <LockOwner>
@end

@implementation TestBedViewController
{
    LockControl *lock;
}

- (void) lockDidUpdate:(LockControl *)sender
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Lock", @selector(lock));
}

- (void) lock
{
    self.navigationItem.rightBarButtonItem = nil;
    lock = [LockControl controlWithTarget:self];
    lock.alpha = 0.0f;
    [self.view addSubview:lock];
    PREPCONSTRAINTS(lock);
    CENTER(lock);
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3f animations:^{
        lock.alpha = 1.0f;
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.view showViewReport:YES];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.nametag = @"Root View";
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Lock", @selector(lock));
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