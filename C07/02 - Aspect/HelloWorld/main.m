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
    NSMutableArray *views;
}

// Public domain images via the National Park Service
- (void) addImageView: (NSString *) source
{
    UIImage *image = [UIImage imageNamed:source];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    
    // Highlight background
    imageView.backgroundColor = AQUA_COLOR;

#define SHOW_ALTERNATIVE    1
#if SHOW_ALTERNATIVE
    imageView.contentMode = UIViewContentModeScaleAspectFit;
#else
    // Enable arbitrary image scaling
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    // Limit aspect at high priority   
    NSLayoutConstraint *constraint;
    CGFloat naturalAspect = image.size.width / image.size.height;
    constraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:naturalAspect constant:0];
    [constraint install:1000];
#endif
    
    // Lower down compression resistance priority
    RESIST(imageView, 250);
    
    [views addObject:imageView];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.nametag = @"Root View";
    
    views = [NSMutableArray array];
    
    [self addImageView:@"bear.jpg"];
    [self addImageView:@"ferret.jpg"];
    [self addImageView:@"pronghorn.jpg"];
    
    // Create a spaced line
    buildLine(views, NSLayoutFormatAlignAllCenterX, 750);
    
    // Each view has the same height
    MATCH_HEIGHT(views[0], views[1]);
    MATCH_HEIGHT(views[0], views[2]);
    
    // Pin first view to the top
    ALIGN_CENTERTOP(views[0], AQUA_INDENT);
    
    // Keep bottom view inside
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:views[2] attribute:NSLayoutAttributeBottom multiplier:1 constant:AQUA_INDENT];
    [constraint install:1000];
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