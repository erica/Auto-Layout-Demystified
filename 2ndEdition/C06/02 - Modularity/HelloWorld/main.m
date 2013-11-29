/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController
- (IBAction) action:(id)sender;
@end

@implementation TestBedViewController
{
    NSMutableArray *views;
    UIView *settingsView;
    UIView *creditsView;
    UIView *spacerTop, *spacerBottom, *spacerLeft, *spacerRight;
}

- (IBAction) action:(NSObject *)sender
{
    NSLog(@"Sender: %@", sender.class.description);
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    UIDeviceOrientation orientation = self.interfaceOrientation;
    BOOL layoutIsPortrait = UIDeviceOrientationIsPortrait(orientation);
    
    // Clean out external constraints
    for (UIView *view in @[settingsView, creditsView])
        [self.view removeConstraints:[self.view constraintsReferencingView:view]];
    
    // Remove spacer constraints
    for (UIView *view in @[spacerBottom, spacerTop, spacerLeft, spacerRight])
    {
        for (NSLayoutConstraint *constraint in view.referencingConstraints)
            [constraint remove];
    }
    
    // Handle Spacer Ambiguity (by providing fallbacks)
    for (UIView *spacer in @[spacerTop, spacerBottom, spacerLeft, spacerRight])
    {
        constrainViewSize(spacer, CGSizeMake(1,1), 1);
        positionView(spacer, CGPointMake(0,0), 1);
    }

    if (IS_IPAD)
    {
        // Align centers horizontally
        for (UIView *view in @[settingsView, creditsView])
            CENTER_H(view);
        
        // Build column
        CONSTRAIN(@"V:|-[spacerTop(==spacerBottom)][settingsView(==creditsView)]-30-[creditsView][spacerBottom]-|", settingsView, creditsView, spacerTop, spacerBottom);
        
        // Constrain widths
        CONSTRAIN_WIDTH(settingsView, 320);
        MATCH_WIDTH(settingsView, creditsView);
        CONSTRAIN_HEIGHT(settingsView, 240);
        MATCH_HEIGHT(settingsView, creditsView);
    }
    else if (layoutIsPortrait)
    {
        // Stretch horizontallyl
        for (UIView *view in @[settingsView, creditsView])
            STRETCH_H(view, AQUA_INDENT);
        
        // Build column
        CONSTRAIN(@"V:|-[spacerTop(==spacerBottom)][settingsView(==creditsView)]-30-[creditsView][spacerBottom]-|", settingsView, creditsView, spacerTop, spacerBottom);
    }
    else
    {
        // Stretch vertically
        for (UIView *view in @[settingsView, creditsView])
            STRETCH_V(view, AQUA_INDENT);

        // Build row
        CONSTRAIN(@"H:|-[spacerLeft(==spacerRight)][settingsView(==creditsView)]-30-[creditsView][spacerRight]-|", settingsView, creditsView, spacerLeft, spacerRight);
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [self updateViewConstraints];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        for (UIView *view in @[settingsView, creditsView])
            view.alpha = 0.0f;
    }];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3f animations:^{
        for (UIView *view in @[settingsView, creditsView])
            view.alpha = 1.0f;
    }];
}

- (UIView *) spacer: (NSString *) name
{
    // Make it, Add it, Name it
    UIView *spacer = [[UIView alloc] init];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:spacer];
    NSString *string = [NSString stringWithFormat:@"SpacerView%@", name];
    spacer.nametag = string;
    return spacer;
}

- (void) buildSpacers
{
    // Build spacers
    spacerTop = [self spacer:@"Top"];
    spacerBottom = [self spacer:@"Bottom"];
    spacerLeft = [self spacer:@"Left"];
    spacerRight = [self spacer:@"Right"];
}

- (void) peek
{
    [self.view addConstraintNames];
    [self.view addViewNames];
    [self.view showViewReport:YES];
    // NSLog(@"%@", self.view.trace);
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = AQUA_COLOR;
    self.view.nametag = @"Root View";
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Peek", @selector(peek));
    
    settingsView = [[[UINib nibWithNibName:@"Settings" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:0] lastObject];
    settingsView.nametag = @"SettingsView";
    
    creditsView = [[[UINib nibWithNibName:@"Credits" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:0] lastObject];
    creditsView.nametag = @"CreditsView";
    
    for (UIView *view in @[settingsView, creditsView])
    {
        [self.view addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self buildSpacers];
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