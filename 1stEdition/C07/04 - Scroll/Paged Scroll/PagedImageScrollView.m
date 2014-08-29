/*
 
 Erica Sadun, http://ericasadun.com
 
 */

// #error Please add the Utility Pack and Art Pack to this project

#import "PagedImageScrollView.h"
#import "Utility.h"

@implementation PagedImageScrollView
{
    NSMutableArray *views;
}

+ (BOOL) requiresConstraintBasedLayout
{
    return YES;
}

- (void) updateContentSize
{
    self.contentSize = CGSizeMake(self.frame.size.width * views.count, self.frame.size.height);
    _pagedContentView.frame = (CGRect){.size = self.contentSize};
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
    self.showsVerticalScrollIndicator = YES;
    self.pagingEnabled = YES;
    
    _pagedContentView = [[UIView alloc] init];
    [self addSubview:_pagedContentView];
    
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
    buildLineWithSpacing(views, NSLayoutFormatAlignAllCenterY, @"", 750);
    pin(views[0], @"H:|[view]");
    pin([views lastObject], @"H:[view]|");
    
    // Update content size and page offset
    [self updateContentSize];
    [self setContentOffset:CGPointMake((CGFloat) _pageNumber * self.frame.size.width, 0)];
}

- (void) addView:(UIView *)view
{
    if (!views)
        views = [NSMutableArray array];
    [views addObject:view];
    
    [self.pagedContentView addSubview:view];
    PREPCONSTRAINTS(view);
    
    [self setNeedsUpdateConstraints];
}
@end
