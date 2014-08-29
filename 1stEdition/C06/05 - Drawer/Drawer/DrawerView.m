/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import "DrawerView.h"
#import "Utility.h"

@implementation DrawerView
{
    NSMutableArray *views;
}

#pragma mark - Layout

- (BOOL) requiresConstraintBasedLayout
{
    return YES;
}

+ (NSArray *) originatedPositionNames
{
    return @[LINE_BUILDING_NAME];
}

- (void) updateConstraints
{
    [super updateConstraints];
    
    NSLayoutConstraint *constraint;

    // Handle MinMax Layout
    
    // Remove prior constraints
    for (NSLayoutConstraint *constraint in [self constraintsNamed:MINMAX_NAME])
        [constraint remove];

    // Maximum Ascent (space available)
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    constraint.nametag = MINMAX_NAME;
    [constraint install:750];
        
    // Minimum Ascent
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1 constant: - _handle.bounds.size.height / 2.0f];
    constraint.nametag = MINMAX_NAME;
    [constraint install:1000];

    // Handle view layout
    for (UIView *view in views)
    {
        // Remove prior constraints
        for (NSLayoutConstraint *constraint in [view constraintsNamed:LINE_BUILDING_NAME matchingView:view])
            [constraint remove];
        
        // Remove competing constraints
        for (NSString *name in _competingPositionNames)
            for (NSLayoutConstraint *constraint in [view constraintsNamed:name matchingView:view])
                [constraint remove];
    }

    if (views.count)
    {
        // Pin the first view to the leading edge
        UIView *view = views[0];
        
        constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:AQUA_INDENT];
        constraint.nametag = LINE_BUILDING_NAME;
        [constraint install:LayoutPriorityFixedWindowSize + 2];
    }
    
    for (UIView *view in views)
    {
        // Center each view vertically in the holder drawer
        constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [constraint install:LayoutPriorityFixedWindowSize + 2];
        constraint.nametag = LINE_BUILDING_NAME;
    }
    
    // Layout the views as a line
    buildLine(views, NSLayoutFormatAlignAllCenterY, LayoutPriorityFixedWindowSize + 2);
}

#pragma mark - View Management

// Report whether the view's layout is being managed by the drawer
- (BOOL) managesViewLayout: (UIView *) view
{
    return [views containsObject:view];
}

// Remove view from drawer management
- (void) removeView: (UIView *) view
{
    [views removeObject:view];

    // Animate any changes
    DrawerView __weak *weakself = self;
    [UIView animateWithDuration:0.3f animations:^{
        [weakself setNeedsUpdateConstraints];
        [weakself.window layoutIfNeeded];
    }];
}

// Add view to drawer management
- (void) addView: (UIView *) view
{
    if (!views)
        views = [NSMutableArray array];
    [views removeObject:view];
    [views addObject:view];
    
    // Animate any changes
    DrawerView __weak *weakself = self;
    [UIView animateWithDuration:0.3f animations:^{
        [weakself setNeedsUpdateConstraints];
        [weakself.window layoutIfNeeded];
    }];
}

#pragma mark - View Creation

- (instancetype) initWithHeight: (CGFloat) height
{
    self = [super initWithFrame:CGRectZero];
    if (!self) return self;
    
    // Store height
    self.drawerHeight = height;

    // Set visuals
    self.backgroundColor = ORANGE_COLOR;
    
    // Add a handle, pinned to the center top
    _handle = [DrawHandle handleWithDrawer:self];
    PREPCONSTRAINTS(_handle);
    CONSTRAIN_SIZE(_handle, _handle.frame.size.width, _handle.frame.size.height);

    // Add a thin black "border"
    UIView *blackView = [[UIView alloc] init];
    blackView.backgroundColor = [UIColor blackColor];
    [self addSubview:blackView];
    PREPCONSTRAINTS(blackView);
    CONSTRAIN_HEIGHT(blackView, 4);
    ALIGN_TOP(blackView, 0);
    STRETCH_H(blackView, 0);
    
    return self;
}

+ (instancetype) holderWithDrawerHeight: (CGFloat) height
{
    id holder = [[self alloc] initWithHeight:height];
    return holder;
}
@end
