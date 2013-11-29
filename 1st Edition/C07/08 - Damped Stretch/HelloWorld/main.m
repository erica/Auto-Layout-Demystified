/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"
#import "AnimationQueue.h"

@interface Squlch : UIView
@end

@implementation Squlch
{
    AnimationQueue *queue;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundColor = ORANGE_COLOR;
        NSArray *array = [self constraintsNamed:@"squlch"];
        for (NSLayoutConstraint *constraint in array)
            constraint.constant = 150;
        [self.superview layoutIfNeeded];
    }];
}

CGFloat damped(CGFloat t)
{
    return  exp(-1.0 * t/3) * cos(t);
}

- (void) animationQueueDidComplete: (id) sender
{
    queue = nil;    
    self.userInteractionEnabled = YES;
}

- (void) squlchToValue: (CGFloat) value
{
    // Retrieve constraints
    NSArray *array = [self constraintsNamed:@"squlch" matchingView:self];
    
    // Update constraints
    for (NSLayoutConstraint *constraint in array)
        constraint.constant = value;
    
    // Enable animation
    [self layoutIfNeeded];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.userInteractionEnabled = NO;
    Squlch __weak *weakself = self;
    
    // Animation Block. Engage!
    AnimationBlock block;
    queue = [[AnimationQueue alloc] init];
    queue.delegate = self;
            
    // Stage one executes immediately
    // Set up any initial conditions here
    [queue enqueue:^{} withDuration:0.0f];
    
    // Determine how far to extend
    CGFloat finalDimension = 100;
    CGFloat stretchAllowance = 50;
    
    // Animation steps in total
    NSInteger numberOfSteps = 24;
    
    // Amount to oscillate
    CGFloat numberOfOscillations = 2;
    CGFloat oscillationDistance = numberOfOscillations * 2 * M_PI;
    
    // Oscillation duration
    CGFloat totalTime = 1.3f;
    CGFloat dT = totalTime / numberOfSteps;    
    
    // Perform oscillation over n steps
    for (NSInteger step = 1; step < numberOfSteps; step++)
    {
        CGFloat progress = (CGFloat) step / (CGFloat) numberOfSteps;
        CGFloat distance = progress * oscillationDistance;
        CGFloat dampValue = damped(distance);
        CGFloat currentDimension = finalDimension + stretchAllowance * dampValue;
        
        block = ^{[weakself squlchToValue:currentDimension];};
        [queue enqueue:block withDuration:dT];
    }
    
    // End with final dimension
    block = ^
    {
        [weakself squlchToValue:finalDimension];
        weakself.backgroundColor = AQUA_COLOR;
    };
    [queue enqueue:block withDuration:0.3f];
    
    // Go
    [queue start];
}
@end

@interface TestBedViewController : UIViewController
{
    NSMutableArray *views;
}
@end

@implementation TestBedViewController
- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create a new item
    Squlch *squlch = [[Squlch alloc] init];
    squlch.backgroundColor = AQUA_COLOR;
    
    // Add a little style
    squlch.layer.borderColor = [UIColor blackColor].CGColor;
    squlch.layer.borderWidth = 4;
    squlch.layer.cornerRadius = 8;
    
    // Make it touchable
    squlch.userInteractionEnabled = YES;
    
    // Add it to the system
    [self.view addSubview:squlch];
    PREPCONSTRAINTS(squlch);
    
    // Lay it out. The size constraints are addressable by name
    CENTER(squlch);
    INSTALL_CONSTRAINTS(750, @"squlch", CONSTRAINTS_SETTING_SIZE(squlch, 100, 100));
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