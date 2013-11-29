/*
 
 Erica Sadun, http://ericasadun.com

 */

// Optionally add the Application Art Pack to this project

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ConstraintUtilities-Install.h"

#define ORANGE_COLOR    [UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f]
#define IS_HORIZONTAL_ALIGNMENT(ALIGNMENT) [@[@(NSLayoutFormatAlignAllLeft), @(NSLayoutFormatAlignAllRight), @(NSLayoutFormatAlignAllLeading), @(NSLayoutFormatAlignAllTrailing), @(NSLayoutFormatAlignAllCenterX), ] containsObject:@(ALIGNMENT)]

NSLayoutAttribute attributeForAlignment(NSLayoutFormatOptions alignment)
{
    switch (alignment)
    {
        case NSLayoutFormatAlignAllLeft:
            return NSLayoutAttributeLeft;
        case NSLayoutFormatAlignAllRight:
            return NSLayoutAttributeRight;
        case NSLayoutFormatAlignAllTop:
            return NSLayoutAttributeTop;
        case NSLayoutFormatAlignAllBottom:
            return NSLayoutAttributeBottom;
        case NSLayoutFormatAlignAllLeading:
            return NSLayoutAttributeLeading;
        case NSLayoutFormatAlignAllTrailing:
            return NSLayoutAttributeTrailing;
        case NSLayoutFormatAlignAllCenterX:
            return NSLayoutAttributeCenterX;
        case NSLayoutFormatAlignAllCenterY:
            return NSLayoutAttributeCenterY;
        case NSLayoutFormatAlignAllBaseline:
            return NSLayoutAttributeBaseline;
        default:
            return NSLayoutAttributeNotAnAttribute;
    }
}

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

- (void) addViews: (NSInteger) howMany
{
    views = [NSMutableArray array];
    
    for (int i = 0; i < howMany; i++)
    {
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = randomColor();
        [self.view addSubview:view];
        
        // Choose fixed or random sizes
//        CGFloat side = 30 + random() % 30; // random size
        CGFloat side = 60; // fixed size
        
        NSArray *constraints;
        
        // Adjust priorities as needed for smaller installations
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(size)]" options:0 metrics:@{@"size":@(side)} views:NSDictionaryOfVariableBindings(view)];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint install:300];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(size)]" options:0 metrics:@{@"size":@(side)} views:NSDictionaryOfVariableBindings(view)];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint install:300];

        [views addObject:view];
    }
}

void pseudoDistributeCenters(NSArray *views, NSLayoutFormatOptions alignment, NSUInteger priority)
{
    if (!views.count)
        return;
    
    if (alignment == 0)
        return;
    
    // Check the alignment for vertical or horizontal placement
    BOOL horizontal = IS_HORIZONTAL_ALIGNMENT(alignment);
    
    // Placement is orthogonal to that alignment
    NSLayoutAttribute placementAttribute = horizontal ? NSLayoutAttributeCenterY : NSLayoutAttributeCenterX;
    NSLayoutAttribute endAttribute = horizontal ? NSLayoutAttributeCenterY : NSLayoutAttributeRight;
    
    // Cast from NSLayoutFormatOptions to NSLayoutAttribute
    NSLayoutAttribute alignmentAttribute = attributeForAlignment(alignment);
    
    // Iterate through the views
    NSLayoutConstraint *constraint;
    for (int i = 0; i < views.count; i++)
    {
        VIEW_CLASS *view = views[i];
        CGFloat multiplier = ((CGFloat) i + 0.5) / ((CGFloat) views.count);
        
        // Install the item position
        constraint = [NSLayoutConstraint
                      constraintWithItem:view
                      attribute:placementAttribute
                      relatedBy:NSLayoutRelationEqual
                      toItem:view.superview
                      attribute:endAttribute
                      multiplier: multiplier
                      constant: 0];
        [constraint install:priority];
        
        // Install alignment
        constraint = [NSLayoutConstraint
                      constraintWithItem:views[0]
                      attribute:alignmentAttribute
                      relatedBy:NSLayoutRelationEqual
                      toItem: view
                      attribute:alignmentAttribute
                      multiplier:1
                      constant:0];
        [constraint install:priority];
    }
}

void pseudoDistributeWithSpacers(VIEW_CLASS *superview, NSArray *views, NSLayoutFormatOptions alignment, NSUInteger priority)
{
    // You pin the first and last items wherever you want
    
    // Must pass views, superview, non-zero alignment
    if (!views.count) return;
    if (!superview) return;
    if (alignment == 0) return;

    // Build disposable spacers
    NSMutableArray *spacers = [NSMutableArray array];
    for (int i = 0; i < views.count; i++)
    {
        [spacers addObject:[[VIEW_CLASS alloc] init]];
        [spacers[i] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [superview addSubview:spacers[i]];
    }
    
    BOOL horizontal = IS_HORIZONTAL_ALIGNMENT(alignment);
    VIEW_CLASS *firstspacer = spacers[0];
    
    // No sizing restriction
//    NSString *format = [NSString stringWithFormat:@"%@:[view1][spacer(==firstspacer)][view2]", horizontal ? @"V" : @"H"];
    
    // Equal sizing restriction
    NSString *format = [NSString stringWithFormat:@"%@:[view1][spacer(==firstspacer)][view2(==view1)]", horizontal ? @"V" : @"H"];

    // Lay out the row or column
    for (int i = 1; i < views.count; i++)
    {
        VIEW_CLASS *view1 = views[i-1];
        VIEW_CLASS *view2 = views[i];
        VIEW_CLASS *spacer = spacers[i-1];

        NSDictionary *bindings = NSDictionaryOfVariableBindings(view1, view2, spacer, firstspacer);
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:alignment metrics:nil views:bindings];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint install:priority];
    }
}

- (void) runSpacerDemo
{
    [self addViews:6];
    pseudoDistributeWithSpacers(self.view, views, NSLayoutFormatAlignAllCenterY, 1000);
    
    UIView *firstView = views[0];
    UIView *lastView = [views lastObject];
    NSArray *constraints;
    
    // Pin first view left, and to the top
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[firstView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstView)];
    [self.view addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[firstView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstView)];
    [self.view addConstraints:constraints];
    
    // Pin last view right
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[lastView]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lastView)];
    [self.view addConstraints:constraints];
    
    // Pin last view center, for half-width layout
//    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//    [constraint install];
}

- (void) runCenteringDemo
{
    [self addViews:6];
    pseudoDistributeCenters(views, NSLayoutFormatAlignAllCenterY, 1000);
}


- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self runSpacerDemo];
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