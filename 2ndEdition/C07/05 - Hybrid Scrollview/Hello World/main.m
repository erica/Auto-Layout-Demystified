/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import UIKit;
@import QuartzCore;

#import "ConstraintPack.h"

// http://developer.apple.com/library/ios/#technotes/tn2154/_index.html

@interface AutoLayoutScrollView : UIScrollView
@property (nonatomic, readonly) UIView *contentView;
@end

@implementation AutoLayoutScrollView
- (instancetype) initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return self;
    
    _contentView = [[UIView alloc] init];
    [self addSubview:_contentView];
    
    return self;
}

- (void) addSubview:(UIView *)view
{
    if (view != _contentView)
        [_contentView addSubview:view];
    else
        [super addSubview:_contentView];
}

- (void) setContentSize:(CGSize)contentSize
{
    _contentView.frame = (CGRect){.size = contentSize};
    [super setContentSize:contentSize];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    AutoLayoutScrollView *scrollView;
}

- (void) viewDidAppear:(BOOL)animated
{
    [scrollView.contentView addConstraintNames];
    [scrollView.contentView showViewReport:YES];
}

UIColor *RandomColor()
{
    static BOOL seeded = NO;
    if (!seeded)
    {
        seeded = YES;
        srandom(time(0));
    }
    return [UIColor colorWithRed:random() / (CGFloat) LONG_MAX
                           green:random() / (CGFloat) LONG_MAX
                            blue:random() / (CGFloat) LONG_MAX
                           alpha:1.0f];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    scrollView = [[AutoLayoutScrollView alloc] init];
    [self.view addSubview:scrollView];
    PREPCONSTRAINTS(scrollView);
    CENTER(scrollView);
    CONSTRAIN_SIZE(scrollView, 240, 240);
    scrollView.layer.borderColor = [UIColor blackColor].CGColor;
    scrollView.layer.borderWidth = 4;
    scrollView.contentSize = CGSizeMake(400, 400);
    scrollView.contentInset = UIEdgeInsetsMake(50, 50, 50, 50);
    
    //    LoadContrastViewsOntoView(scrollView.contentView);

    NSMutableArray *views = [NSMutableArray array];
    for (int i = 0; i < 5; i++)
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = RandomColor();
        view.nametag = [NSString stringWithFormat:@"V%d", i];
        
        [views addObject:view];
        [scrollView addSubview:view];
        
        PREPCONSTRAINTS(view);
        CONSTRAIN_MIN_WIDTH(view, 40, 1);
        CONSTRAIN_MIN_HEIGHT(view, 100, 1);
        MATCH_SIZE(view, views[0]);
        ALIGN_PAIR_BOTTOM(view, views[0]);
    }
    ALIGN_CENTERLEFT(views[0], AQUA_SPACE);
    ALIGN_RIGHT(views.lastObject, AQUA_SPACE);
    BuildLineWithSpacing(views, NSLayoutFormatAlignAllTop, @"-", 1000);
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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