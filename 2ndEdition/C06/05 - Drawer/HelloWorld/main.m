/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"
#import "Color-Utilities.h"

#import "DraggableView.h"
#import "DrawerView.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    DrawerView *holder;
    NSMutableArray *views;
}

- (void) viewWillAppear:(BOOL)animated
{
    [holder updateConstraints];
    [self.view.window layoutIfNeeded];
}

// Prepare for rotation by moving non-drawer items up
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    TestBedViewController __weak *weakself = self;
    
    [UIView animateWithDuration:duration animations:^{
        
        // Re-layout holder
        [holder updateConstraints];

        // Move non-drag views up
        int i = 0;
        for (DraggableView *view in views)
            if (![holder managesViewLayout:view])
                [view moveToPosition:CGPointMake(++i * 40, 40)];

        // Layout all constraints
        [weakself.view.window layoutIfNeeded];
    }];
}

// Show debug information
- (void) peek
{
    [self.view showViewReport:YES];
}

// Listen for the start and end of object drags
- (void) establishNotificationHandlers
{
    // Check the start of drag
    [[NSNotificationCenter defaultCenter] addObserverForName:DRAG_START_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        // Remove dragged objects from the drawer
        UIView *view = note.object;
        [holder removeView:view];
    }];

    // Check the end of drag
    [[NSNotificationCenter defaultCenter] addObserverForName:DRAG_END_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        // Test dragged objects for position, adding
        // to the drawer when overlapped
        UIView *view = note.object;
        if (CGRectIntersectsRect(view.frame, holder.frame))
            [holder addView:view];
        else
            [holder removeView:view];
    }];
    
    // Check for double taps
    [[NSNotificationCenter defaultCenter] addObserverForName:DOUBLE_TAP_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
     {
         DraggableView *view = note.object;
         if ([holder managesViewLayout:view])
         {
             [UIView animateWithDuration:0.2f animations:^{
                 [holder removeView:view];
                 [view moveToPosition:CGPointMake(30 + random() % 50, 30 + random() % 50)];
                 [self.view layoutIfNeeded];
             }];
         }
         else
             [holder addView:view];
     }];
}

- (void) loadView
{
    NSLayoutConstraint *constraint;
    
    // Root View
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.nametag = @"Root View";
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Peek", @selector(peek));
    
    // Build Drawer
    CGFloat height = 130.0f;
    holder = [DrawerView holderWithDrawerHeight:height];
    PREPCONSTRAINTS(holder);
    [self.view addSubview:holder];
    
    // Register dragging constraints
    holder.competingPositionNames = [DraggableView originatedPositionNames];

    // Stretch horizontally, fix drawer size
    STRETCH_H(holder, 0);
    CONSTRAIN_HEIGHT(holder, height);
    
    // Add the drawer's handle
    [self.view addSubview:holder.handle];
    constraint = [NSLayoutConstraint constraintWithItem:holder.handle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:holder attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    constraint.nametag = @"Handle Placement";
    [constraint install:1000];
    constraint = [NSLayoutConstraint constraintWithItem:holder.handle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:holder attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    constraint.nametag = @"Handle Placement";
    [constraint install:1000];
        
    // Place the top of the drawer
    constraint =  [NSLayoutConstraint constraintWithItem:holder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-height];
    constraint.nametag = DRAWER_POSITION_NAME;
    [constraint install:600];
    
    // Build some views
    views = [NSMutableArray array];
    int numberOfViews = IS_IPAD ? 10 : 4;
    for (int i = 0; i < numberOfViews; i++)
    {
        // Create a view and stylize it
        DraggableView *view = [DraggableView randomView];
        view.nametag = [NSString stringWithFormat:@"View #%d", i + 1];
        view.layer.cornerRadius = 8;
        view.layer.borderWidth = 4;
        view.layer.borderColor = [UIColor blackColor].CGColor;
        
        // Register drawer-specific constraints
        view.competingPositionNames = [DrawerView originatedPositionNames];
        
        // Add the view
        PREPCONSTRAINTS(view);
        [self.view addSubview:view];
        [views addObject:view];

        // Constrain size and initial position
        CONSTRAIN_SIZE(view, 60, 60);
        [view moveToPosition:CGPointMake((i + 1) * 40, 40)];
        
        // Establish basic boundaries
        for (NSString *format in @[
             @"H:|-(>=20)-[view]",
             @"H:[view]-(>=20)-|",
             @"V:|-(>=8)-[view]"])
        {
            NSArray *constraints = CONSTRAINTS(format, view);
            INSTALL_CONSTRAINTS(750, @"Boundaries", constraints);
        }
        
        // Enable view dragging
        [view enableDragging:YES];
    }
    
    // Listen for view movement
    [self establishNotificationHandlers];
}
@end

#pragma mark - Nav Rotation

@interface UINavigationController (FullRotationSupportOniPhone)
@end

@implementation UINavigationController (FullRotationSupportOniPhone)
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
@end

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