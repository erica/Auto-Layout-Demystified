/*
 
 Erica Sadun, http://ericasadun.com

 */

// Optionally add the Application Art Pack to this project

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define ORANGE_COLOR    [UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    NSMutableArray *views;
}

#pragma mark - Stretch Views
void stretchToSuperview(UIView *view, CGFloat indent, NSUInteger priority)
{
    for (NSString *format in @[
         @"H:|-indent-[view(>=0)]-indent-|",
         @"V:|-indent-[view(>=0)]-indent-|"
         ])
    {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:@{@"indent":@(indent)} views:@{@"view": view}];
        [view.superview addConstraints:constraints];
    }
}

#pragma mark - Create Views

UIColor *randomColor()
{
    UIColor *theColor = [UIColor colorWithRed:((random() % 255) / 255.0f)
                                        green:((random() % 255) / 255.0f)
                                         blue:((random() % 255) / 255.0f)
                                        alpha:1.0f];
    return theColor;
}

- (void) addViews: (NSInteger) howMany
{
    views = [NSMutableArray array];
    
    for (int i = 0; i < howMany; i++)
    {
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = randomColor();
        [self.view addSubview:view];

        [views addObject:view];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    for (UIView *view in self.view.subviews)
        NSLog(@"View: %@", NSStringFromCGRect(view.frame));
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addViews:4];
    for (int i = 0; i < 4; i++)
        stretchToSuperview(views[i], 20 * (i + 1), 500);
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
    
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    tbvc.edgesForExtendedLayout = UIRectEdgeNone;
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