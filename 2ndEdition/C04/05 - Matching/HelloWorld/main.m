/*
 
 Erica Sadun, http://ericasadun.com

 */

// Optionally add the Application Art Pack to this project

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ConstraintUtilities-Install.h"

#define ORANGE_COLOR    [UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    NSMutableArray *views;
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

void matchSizes(NSArray *views, NSInteger axis, NSUInteger priority)
{
    if (!views.count)
        return;

    NSString *format = axis ? @"V:[view2(==view1@priority)]" : @"H:[view2(==view1@priority)]";
    
    UIView *view1 = views[0];
    for (int i = 1; i < views.count; i++)
    {
        UIView *view2 = views[i];
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:@{@"priority":@(priority)} views:NSDictionaryOfVariableBindings(view1, view2)];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint install];
    }
}

#define IS_HORIZONTAL_ALIGNMENT(ALIGNMENT) [@[@(NSLayoutFormatAlignAllLeft), @(NSLayoutFormatAlignAllRight), @(NSLayoutFormatAlignAllLeading), @(NSLayoutFormatAlignAllTrailing), @(NSLayoutFormatAlignAllCenterX), ] containsObject:@(ALIGNMENT)]

void buildLineWithSpacing(NSArray *views, NSLayoutFormatOptions alignment, NSString *spacing, NSUInteger priority)
{
    if (!views.count)
        return;
    
    VIEW_CLASS *view1, *view2;
    NSInteger axis = IS_HORIZONTAL_ALIGNMENT(alignment);
    NSString *axisString = (axis == 0) ? @"H:" : @"V:";
    
    NSString *format = [NSString stringWithFormat:@"%@[view1]%@[view2]", axisString, spacing];
    
    for (int i = 1; i < views.count; i++)
    {
        view1 = views[i-1];
        view2 = views[i];
        NSDictionary *bindings = NSDictionaryOfVariableBindings(view1, view2);
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:alignment metrics:nil views:bindings];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint install:priority];
    }
}

void constrainViewSize(UIView *view, CGSize size, NSUInteger priority)
{
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSDictionary *metrics = @{@"width":@(size.width), @"height":@(size.height), @"priority":@(priority)};
    
    for (NSString *formatString in @[
         @"H:[view(==width@priority)]",
         @"V:[view(==height@priority)]",
         ])
    {
        NSArray *constraints = [NSLayoutConstraint
                                constraintsWithVisualFormat:formatString
                                options:0 metrics:metrics views:bindings];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint install];
    }
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
    
    NSArray *constraints;
    UIView *view = views[0];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]" options:0 metrics:nil views:@{@"view":view}];
    for (NSLayoutConstraint *constraint in constraints)
        [constraint install];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]" options:0 metrics:nil views:@{@"view":view}];
    for (NSLayoutConstraint *constraint in constraints)
        [constraint install];
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
    
    [self addViews:6];
    constrainViewSize(views[0], CGSizeMake(40, 40), 1);
    buildLineWithSpacing(views, NSLayoutFormatAlignAllCenterX, @"-", 500);
    matchSizes(views, 0, 500);
    matchSizes(views, 1, 500);
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