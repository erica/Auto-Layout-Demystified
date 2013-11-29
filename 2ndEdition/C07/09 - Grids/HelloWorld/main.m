/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    NSMutableArray *buttons;
    NSMutableArray *labels;
    NSMutableArray *switches;
    
}

- (UILabel *) createLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (void) callback: (id) sender
{
    // no op
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    buttons = [NSMutableArray array];
    switches = [NSMutableArray array];
    labels = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++)
    {
        UILabel *l = [self createLabel];
        l.text = [NSString stringWithFormat:@"Label %d", i+1];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:l];
        [labels addObject:l];
        HUG(l, 750);
        RESIST(l, 750);
        
        
        UISwitch *s = [[UISwitch alloc] init];
        s.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:s];
        [switches addObject:s];
        s.tag = 10 + i + 1; // to identify the view
        CALLBACK_VAL(s, @selector(callback:));
        
        UIButton *b = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        b.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:b];
        [buttons addObject:b];
        b.tag = 100 + i + 1; // to identify the view
        CALLBACK_PRESS(b, @selector(callback:));

        // Layout each row
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=20-[l]-[s]-(>=0)-[b]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(l, s, b)];
        [self.view addConstraints:constraints];
        
        // Attempt to pin each label to the left using a low priority
        pinWithPriority(l, @"H:|-[view]", nil, 300);
    }
    
    // Build a vertical column based on switches, the tallest of the views
    pseudoDistributeWithSpacers(self.view, switches, NSLayoutFormatAlignAllLeading, 500);
    pin(buttons[0], @"V:|-[view]");
    pin([buttons lastObject], @"V:[view]-|");
    
    // [labels[2] setText:@"Much Longer Label"];    
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