/*
 
 Erica Sadun, http://ericasadun.com

 */

// Optionally add the Application Art Pack in to this project

#import <UIKit/UIKit.h>

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *subview = [[[NSBundle mainBundle] loadNibNamed:@"View" owner:self options:nil] lastObject];
    [self.view addSubview:subview];
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint;
    
    // Center it
    constraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self.view addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    // Set its aspect
    constraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:subview attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    // Constrain it to the superview's size
    constraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:-40];
    [self.view addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:-40];
    [self.view addConstraint:constraint];
    
    // Add a weak "match size" constraint
    constraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:-40];
    constraint.priority = 100;
    [self.view addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:-40];
    constraint.priority = 100;
    [self.view addConstraint:constraint];

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