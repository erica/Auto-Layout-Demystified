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

#pragma mark - Constrain Size
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
        [view addConstraints:constraints];
    }
}

void constrainMinimumViewSize(UIView *view, CGSize size, NSUInteger priority)
{
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSDictionary *metrics = @{@"width":@(size.width), @"height":@(size.height), @"priority":@(priority)};
    
    for (NSString *formatString in @[
         @"H:[view(>=width@priority)]",
         @"V:[view(>=height@priority)]",
         ])
    {
        NSArray *constraints = [NSLayoutConstraint
                                constraintsWithVisualFormat:formatString
                                options:0 metrics:metrics views:bindings];
        [view addConstraints:constraints];
    }
}

void constrainMaximumViewSize(UIView *view, CGSize size, NSUInteger priority)
{
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSDictionary *metrics = @{@"width":@(size.width), @"height":@(size.height), @"priority":@(priority)};
    
    for (NSString *formatString in @[
         @"H:[view(<=width@priority)]",
         @"V:[view(<=height@priority)]",
         ])
    {
        NSArray *constraints = [NSLayoutConstraint
                                constraintsWithVisualFormat:formatString
                                options:0 metrics:metrics views:bindings];
        [view addConstraints:constraints];
    }
}


#pragma mark - Create Views

UIColor *randomColor()
{
    UIColor *theColor = [UIColor colorWithRed:((random() % 255) / 255.0f) green:((random() % 255) / 255.0f) blue:((random() % 255) / 255.0f) alpha:1.0f];
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

- (void) centerView: (UIView *) view
{
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self.view addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self.view addConstraint:constraint];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addViews:4];
    for (int i = 0; i < 4; i++)
    {
        [self centerView:views[i]];
        constrainViewSize(views[i], CGSizeMake((8 - i) * 20, (8 - i) * 20), 500);
//        constrainMinimumViewSize(views[i], CGSizeMake((8 - i) * 20, (8 - i) * 20), 500);
    }
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