/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

@interface UINavigationController (FullRotationSupportOniPhone)
@end

@implementation UINavigationController (FullRotationSupportOniPhone)
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIView *exampleView;
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    BOOL layoutIsPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    
    // Remove constraints referencing exampleView
    for (NSLayoutConstraint *constraint in exampleView.referencingConstraintsInSuperviews) // C05
        [constraint remove];
    
    // Re-establish position constraints
    if (layoutIsPortrait)
    {
        ALIGN_CENTERTOP(exampleView, AQUA_INDENT);
    }
    else
    {
        ALIGN_CENTERRIGHT(exampleView, AQUA_INDENT);
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^
     {
         [self updateViewConstraints];
     }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self updateViewConstraints];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    exampleView = [[UIView alloc] init];
    exampleView.backgroundColor = AQUA_COLOR;
    CONSTRAIN_SIZE(exampleView, 100, 80);
    [self.view addSubview:exampleView];
    exampleView.translatesAutoresizingMaskIntoConstraints = NO;
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