/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Color-Utilities.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController
{
    NSMutableArray *views;
}
@end

@implementation TestBedViewController

- (void) setRandomPosition: (UIView *) view
{
    CGFloat randomX = (double) random() / (double) LONG_MAX;
    CGFloat randomY = (double) random() / (double) LONG_MAX;
    
    NSArray *constraints = [view constraintsNamed:@"View Position" matchingView:view];
    [self.view removeConstraints:constraints];

    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTrailing multiplier:randomX constant:0];
    constraint.nametag = @"View Position";
    [constraint install:500];
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeBottom multiplier:randomY constant:0];
    constraint.nametag = @"View Position";
    [constraint install:500];
}

- (void) randomize
{
    TestBedViewController __weak *weakself = self;
    [UIView animateWithDuration:0.3f animations:^
    {
        for (UIView *view in views)
            [weakself setRandomPosition:view];
        [weakself.view layoutIfNeeded];
    }];

}

- (void) limitToSuperview: (UIView *) view withInset: (CGFloat) inset
{
    if (!view || !view.superview)
        return;
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSDictionary *metrics = @{@"inset":@(inset)};
    
    for (NSString *format in @[
         @"H:|->=inset-[view]",
         @"H:[view]->=inset-|",
         @"V:|->=inset-[view]",
         @"V:[view]->=inset-|"])
    {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:bindings];
        [self.view addConstraints:constraints];
    }
}

- (void) addViews: (NSInteger) numberOfViews
{
    if (!views)
        views = [NSMutableArray array];
    
    for (int i = 0; i < numberOfViews; i++)
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = randomColor();
        PREPCONSTRAINTS(view);
        [self.view addSubview:view];
        [views addObject:view];
        
        INSTALL_CONSTRAINTS(500, @"View Position", CONSTRAINTS_POSITION(view, 30 + i * 10, 30 + i * 10));
        CONSTRAIN_SIZE(view, 80, 80);
        
        // Stylize
        view.layer.borderColor = [UIColor blackColor].CGColor;
        view.layer.borderWidth = 4;
        view.layer.cornerRadius = 20;
        
        // Establish boundaries
        [self limitToSuperview:view withInset:0];
    }
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Randomize", @selector(randomize));

    [self addViews:5];
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
    _window.tintColor = [UIColor blackColor];
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