/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "PagedImageScrollView.h"
#import "ConstraintPack.h"

@implementation AutoLayoutScrollView
- (void) _commonSetupAutoLayoutScrollView
{
    self.showsHorizontalScrollIndicator = YES;
    self.showsVerticalScrollIndicator = NO;
    self.bounces = NO;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return self;
    
    // Create custom content view using Autosizing
    _customContentView = [[UIView alloc]
                          initWithFrame: (CGRect){.size=frame.size}];
    [self addSubview:_customContentView];
    [self _commonSetupAutoLayoutScrollView];
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return self;
    
    // Create custom content view using Autosizing
    _customContentView = [[UIView alloc]
                          initWithFrame: (CGRect){.size=self.frame.size}];
    [self addSubview:_customContentView];
    [self _commonSetupAutoLayoutScrollView];
    
    return self;
}

// Override addSubview: so new views are added
// to the content view

- (void) addSubview:(UIView *)view
{
    if (view != _customContentView)
        [_customContentView addSubview:view];
    else
        [super addSubview:_customContentView];
}

// When the content size changes, adjust the
// custom content view as well

- (void) setContentSize:(CGSize)contentSize
{
    _customContentView.frame = (CGRect){.size = contentSize};
    [super setContentSize:contentSize];
}
@end

@implementation PagedImageScrollView
{
    NSMutableArray *views;
}

+ (BOOL) requiresConstraintBasedLayout
{
    return YES;
}

- (void) dealloc
{
    [self removeObserver:self forKeyPath:@"bounds"];
}

- (void) updateContentSize
{
    CGFloat width = self.frame.size.width * views.count;
    self.contentSize = CGSizeMake(width, self.frame.size.height);
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([keyPath isEqualToString:@"bounds"])
        [self updateContentSize];
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return self;
    
    self.backgroundColor = [UIColor blackColor];

    self.showsHorizontalScrollIndicator = YES;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.contentOffset = CGPointZero;
    self.contentSize = CGSizeZero;
    _pageNumber = 0;

    [self addObserver:self
           forKeyPath:@"bounds"
              options:NSKeyValueObservingOptionNew
              context:NULL];    
    
    return self;
}

- (void) updateConstraints
{
    [super updateConstraints];
    
    if (!views.count)
        return;
    
    // Clean up previous constraints
    for (UIView *view in views)
    {
        NSArray *constraints = [view referencingConstraintsInSuperviews];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint remove];
    }
    
    // Layout views vertically, matched to scrollview
    for (UIView *view in views)
    {
        // Center view vertically
        CENTER_V(view);
        
        // Match size to the scrollview width
        INSTALL_CONSTRAINTS(500, nil, CONSTRAINT_MATCHING_WIDTH(view, self));
    }
    
    // Lay out the views in a horizontal row with flush alignment
    BuildLineWithSpacing(views, NSLayoutFormatAlignAllCenterY, @"", 750);
    Pin(views[0], @"H:|[view]");
    Pin([views lastObject], @"H:[view]|");
    
    // Update content size and page offset
    [self updateContentSize];
    [self setContentOffset:CGPointMake((CGFloat) _pageNumber * self.frame.size.width, 0)];
}

- (void) addView:(UIView *)view
{
    if (!views)
        views = [NSMutableArray array];
    [views addObject:view];
    
    [self.customContentView addSubview:view];
    PREPCONSTRAINTS(view);
    
    [self setNeedsUpdateConstraints];
}
@end
