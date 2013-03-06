/*
 
 Erica Sadun, http://ericasadun.com

 */

// Public domain images via the National Park Service

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

#import "PagedImageScrollView.h"

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
@end

@implementation TestBedViewController
{
    NSMutableArray *views;
    
    PagedImageScrollView *scrollView;
    UIPageControl *pageControl;
}

- (void) addImageView: (NSString *) source
{
    UIImage *image = [UIImage imageNamed:source];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    PREPCONSTRAINTS(imageView);
    
    // Enable arbitrary image scaling
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    // Limit aspect at high priority   
    NSLayoutConstraint *constraint;
    CGFloat naturalAspect = image.size.width / image.size.height;
    constraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:naturalAspect constant:0];
    [constraint install:1000];
    
    // Reduce compression resistance priority
    RESIST(imageView, 250);
    
    [views addObject:imageView];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Hide views in anticipation of repaging
    [UIView animateWithDuration:duration / 2 animations:^{
        [pageControl setAlpha:0.0f];
        [scrollView setAlpha:0.0f];
    }];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Update constraints and show views again
    [scrollView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.15f animations:^{
        [pageControl setAlpha:1.0f];
        [scrollView setAlpha:1.0f];
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    [scrollView setNeedsUpdateConstraints];
}

// Update the page control after scrolling
- (void) scrollViewDidEndDecelerating: (id) sender
{
    CGFloat distance = scrollView.contentOffset.x / scrollView.contentSize.width;
    NSInteger page =  distance * pageControl.numberOfPages;
    pageControl.currentPage = page;
    scrollView.pageNumber = page;
}

- (void) inspect
{
    NSLog(@"Scroll frame: %@", scrollView.readableFrame);
    NSLog(@"Scroll content size: %@", SIZESTRING(scrollView.contentSize));
    NSLog(@"Scroll content offset: %@", POINTSTRING(scrollView.contentOffset));
    NSLog(@"Expected offset: %f", scrollView.pageNumber * scrollView.frame.size.width);
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Inspect", @selector(inspect));

    // Build the child views
    views = [NSMutableArray array];
    for (NSString *string in @[@"bear.jpg", @"ferret.jpg", @"pronghorn.jpg", @"bison.jpg", @"prariedog.jpg"])
        [self addImageView:string];
    
    // Add a scroll view
    scrollView = [[PagedImageScrollView alloc] init];
    scrollView.delegate = self;
    PREPCONSTRAINTS(scrollView);
    [self.view addSubview:scrollView];

    // Add a page control as the scrollview's sibling
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = views.count;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor blackColor];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    PREPCONSTRAINTS(pageControl);
    
    // Add the child views
    for (UIView *view in views)
        [scrollView addView:view];

    // Center the scroll view horizontally
    CENTER_H(scrollView);
    
    // Place page control above the scrollview, matching left and right
    INSTALL_CONSTRAINTS(950, nil, CONSTRAINTS(@"V:[pageControl(30)][scrollView]", scrollView, pageControl));
    ALIGN_PAIR_LEFT(scrollView, pageControl);
    ALIGN_PAIR_RIGHT(scrollView, pageControl);
    
    // Force the scrollview aspect
    INSTALL_CONSTRAINTS(1000, nil, CONSTRAINT_SETTING_ASPECT(scrollView, 1));
    
    // Move scrollView towards vertical center
    INSTALL_CONSTRAINTS(500, nil, CONSTRAINT_CENTERING_V(scrollView));
    
    // Create overall layout requests    
    INSTALL_CONSTRAINTS(750, nil, CONSTRAINTS(@"H:|-[scrollView]-|", scrollView));
    INSTALL_CONSTRAINTS(750, nil, CONSTRAINTS(@"V:|-[pageControl][scrollView]-|", pageControl, scrollView));
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