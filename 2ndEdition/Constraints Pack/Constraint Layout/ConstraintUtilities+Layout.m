/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "ConstraintUtilities+Layout.h"
#import "ConstraintUtilities+Matching.h"
#import "NametagUtilities.h"

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
#import "NSView+BackgroundColor.h"
#endif

#pragma mark - Utility

// Paranoia in action.
NSLayoutAttribute AttributeForAlignment(NSLayoutFormatOptions alignment)
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

BOOL ConstraintIsHorizontal(NSLayoutConstraint *constraint)
{
    return IS_HORIZONTAL_ATTRIBUTE(constraint.firstAttribute);
}

#pragma mark - Visibility

// Constrain within superview with minimum sizing
void SizeAndConstrainToSuperview(VIEW_CLASS *view, float side, NSUInteger  priority)
{
    if (!view || !view.superview)
        return;
    
    NSDictionary *metrics = @{@"side":@(side)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    
    for (NSString *format in @[
         @"H:|->=0-[view(==side)]",
         @"H:[view]->=0-|",
         @"V:|->=0-[view(==side)]",
         @"V:[view]->=0-|"])
    {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:bindings];
        InstallConstraints(constraints, priority, @"Constrain to Superview");
    }
}

// Constrain to superview
void ConstrainToSuperview(VIEW_CLASS *view, NSUInteger priority)
{
    if (!view || !view.superview)
        return;
    
    for (NSString *format in @[
                               @"H:|->=0-[view]",
                               @"H:[view]->=0-|",
                               @"V:|->=0-[view]",
                               @"V:[view]->=0-|"])
    {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:@{@"view":view}];
        InstallConstraints(constraints, priority, @"Constrain to Superview");
    }
}

#pragma mark - Stretching
void StretchHorizontallyToSuperview(VIEW_CLASS *view, CGFloat indent, NSUInteger priority)
{
    NSString *format = @"H:|-indent-[view]-indent-|";
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSDictionary *metrics = @{@"indent":@(indent)};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:bindings];
    InstallConstraints(constraints, priority, @"Stretch to Superview");
}

void StretchVerticallyToSuperview(VIEW_CLASS *view, CGFloat indent, NSUInteger priority)
{
    NSString *format = @"V:|-indent-[view]-indent-|";
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSDictionary *metrics = @{@"indent":@(indent)};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:bindings];
    InstallConstraints(constraints, priority, @"Stretch to Superview");
}

void StretchToSuperview(VIEW_CLASS *view, CGFloat indent, NSUInteger priority)
{
    StretchHorizontallyToSuperview(view, indent, priority);
    StretchVerticallyToSuperview(view, indent, priority);
}

#pragma mark - Sizing
void _ConstrainViewSize(VIEW_CLASS *view, CGSize size, NSUInteger priority, NSString *relation)
{
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSDictionary *metrics = @{@"width":@(size.width), @"height":@(size.height)};
    
    for (NSString *format in @[
         [NSString stringWithFormat:@"H:[view(%@width)]", relation],
         [NSString stringWithFormat:@"V:[view(%@height)]", relation],
         ])
    {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:bindings];
        InstallConstraints(constraints, priority, @"Sizing");
    }
}

void ConstrainViewSize(VIEW_CLASS *view, CGSize size, NSUInteger priority)
{
    _ConstrainViewSize(view, size, priority, @"==");
}

void ConstrainMinimumViewSize(VIEW_CLASS *view, CGSize size, NSUInteger priority)
{
    _ConstrainViewSize(view, size, priority, @">=");
}

void ConstrainMaximumViewSize(VIEW_CLASS *view, CGSize size, NSUInteger priority)
{
    _ConstrainViewSize(view, size, priority, @"<=");
}

#pragma mark - Matching

void MatchSizeH(VIEW_CLASS *view1, VIEW_CLASS *view2, NSUInteger priority)
{
    NSString *formatString = @"H:[view1(==view2)]";
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view1, view2);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:bindings];
    InstallConstraints(constraints, priority, @"Match Horizontal Size");
}

void MatchSizeV(VIEW_CLASS *view1, VIEW_CLASS *view2, NSUInteger priority)
{
    NSString *formatString = @"V:[view1(==view2)]";
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view1, view2);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:bindings];
    InstallConstraints(constraints, priority, @"Match Vertical Size");}

void MatchSize(VIEW_CLASS *view1, VIEW_CLASS *view2, NSUInteger priority)
{
    MatchSizeH(view1, view2, priority);
    MatchSizeV(view1, view2, priority);
}

void MatchSizesH(NSArray *views, NSUInteger priority)
{
    if (views.count < 2) return;
    VIEW_CLASS *baseView = views[0];
    for (int i = 1; i < views.count; i++)
        MatchSizeH(baseView, views[i], priority);
}

void MatchSizesV(NSArray *views, NSUInteger priority)
{
    if (views.count < 2) return;
    VIEW_CLASS *baseView = views[0];
    for (int i = 1; i < views.count; i++)
        MatchSizeV(baseView, views[i], priority);
}

#pragma mark - Rows and Columns
void BuildLineWithSpacing(NSArray *views, NSLayoutFormatOptions alignment, NSString *spacing, NSUInteger priority)
{
    if (!views.count)
        return;
    
    VIEW_CLASS *view1, *view2;
    NSInteger axis = IS_HORIZONTAL_ALIGNMENT(alignment);
    NSString *axisString = (axis == 0) ? @"H:" : @"V:";
    
    NSString *format = [NSString stringWithFormat:@"%@[view1]%@[view2]", axisString, spacing];
    
    for (int i = 1; i < views.count; i++)
    {
        view1 = views[i-1];
        view2 = views[i];
        NSDictionary *bindings = NSDictionaryOfVariableBindings(view1, view2);
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings];
        InstallConstraints(constraints, priority, @"Build Line");
    }
}

void BuildLine(NSArray *views, NSLayoutFormatOptions alignment, NSUInteger priority)
{
    BuildLineWithSpacing(views, alignment, @"-", priority);
}

void PseudoDistributeCenters(NSArray *views, NSLayoutFormatOptions alignment, NSUInteger priority)
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
    NSLayoutAttribute alignmentAttribute = AttributeForAlignment(alignment);
    
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

void PseudoDistributeWithSpacers(VIEW_CLASS *superview, NSArray *views, NSLayoutFormatOptions alignment, NSUInteger priority)
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
    
    // No sizing restriction between views
    NSString *format = [NSString stringWithFormat:@"%@:[view1][spacer(==firstspacer)][view2]", horizontal ? @"V" : @"H"];
    
    // Equal sizing restriction
    // NSString *format = [NSString stringWithFormat:@"%@:[view1][spacer(==firstspacer)][view2(==view1)]", horizontal ? @"V" : @"H"];
    
    // Lay out the row or column
    for (int i = 1; i < views.count; i++)
    {
        VIEW_CLASS *view1 = views[i-1];
        VIEW_CLASS *view2 = views[i];
        VIEW_CLASS *spacer = spacers[i-1];
        
        NSDictionary *bindings = NSDictionaryOfVariableBindings(view1, view2, spacer, firstspacer);
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:alignment metrics:nil views:bindings];
        InstallConstraints(constraints, priority, @"PseudoDistribution");
    }
}

// Create equal-sized spacers to float the view horizontally
void FloatViewsH(VIEW_CLASS *firstView, VIEW_CLASS *lastView, NSUInteger priority)
{
    if (!firstView.superview) return;
    if (!lastView.superview) return;
    
    VIEW_CLASS *nca = [firstView nearestCommonAncestorToView:lastView];
    if (!nca) return;
    if (nca == firstView)
        nca = firstView.superview;

    // Create and install spacers
    VIEW_CLASS *spacer1 = [[VIEW_CLASS alloc] init];
    VIEW_CLASS *spacer2 = [[VIEW_CLASS alloc] init];
    [nca addSubview:spacer1];
    [nca addSubview:spacer2];
    PREPCONSTRAINTS(spacer1);
    PREPCONSTRAINTS(spacer2);

    // To assist with debugging, this gives the spacer a height of 40
    for (VIEW_CLASS *view in @[spacer1, spacer2])
    {
        view.nametag = @"SpacerH";
        InstallConstraints([NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)], 1, nil);
    }
    
    // Add spacers to left and right
    BuildLineWithSpacing(@[spacer1, firstView], NSLayoutFormatAlignAllCenterY, @"", priority);
    BuildLineWithSpacing(@[lastView, spacer2], NSLayoutFormatAlignAllCenterY, @"", priority);
   
    // Hug edges, match sizes
    AlignView(spacer1, NSLayoutAttributeLeading, 0, priority);
    AlignView(spacer2, NSLayoutAttributeTrailing, 0, priority);
    MatchSizeH(spacer1, spacer2, priority);
}

// Create equal-sized spacers to float the view vertically
void FloatViewsV(VIEW_CLASS *firstView, VIEW_CLASS *lastView, NSUInteger priority)
{
    if (!firstView.superview) return;
    if (!lastView.superview) return;
    
    VIEW_CLASS *nca = [firstView nearestCommonAncestorToView:lastView];
    if (!nca) return;
    if (nca == firstView)
        nca = firstView.superview;
    
    // Create and install spacers
    VIEW_CLASS *spacer1 = [[VIEW_CLASS alloc] init];
    VIEW_CLASS *spacer2 = [[VIEW_CLASS alloc] init];
    [nca addSubview:spacer1];
    [nca addSubview:spacer2];
    PREPCONSTRAINTS(spacer1);
    PREPCONSTRAINTS(spacer2);
    
    // To assist with debugging, this gives the spacer a width of 40
    for (VIEW_CLASS *view in @[spacer1, spacer2])
    {
        InstallConstraints([NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)], 1, nil);
        view.nametag = @"SpacerV";
    }
    
    // Add spacers to top and bottom
    BuildLineWithSpacing(@[spacer1, firstView], NSLayoutFormatAlignAllCenterX, @"", priority);
    BuildLineWithSpacing(@[lastView, spacer2], NSLayoutFormatAlignAllCenterX, @"", priority);
    
    // Hug edges, match sizes
    AlignView(spacer1, NSLayoutAttributeTop, 0, priority);
    AlignView(spacer2, NSLayoutAttributeBottom, 0, priority);
    MatchSizeV(spacer1, spacer2, priority);
}

#pragma mark - Alignment
void AlignView(VIEW_CLASS *view, NSLayoutAttribute attribute, NSInteger inset, NSUInteger priority)
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:attribute multiplier:1 constant:inset];
    [constraint install:priority];
}

void CenterView(VIEW_CLASS *view, NSUInteger priority)
{
    AlignView(view, NSLayoutAttributeCenterX, 0, priority);
    AlignView(view, NSLayoutAttributeCenterY, 0, priority);
}

void CenterViewH(VIEW_CLASS *view, NSUInteger priority)
{
    AlignView(view, NSLayoutAttributeCenterX, 0, priority);
}

void CenterViewV(VIEW_CLASS *view, NSUInteger priority)
{
    AlignView(view, NSLayoutAttributeCenterY, 0, priority);
}

#pragma mark - Position

// NOTE! This uses Left to position the view, and not Leading
// For this reason, you cannot generate a format from this constraint
// An exact position will not be overriden by internationalization
NSLayoutConstraint *ConstraintPositioningViewH(VIEW_CLASS *view, CGFloat x)
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:x];
    return constraint;
}

NSLayoutConstraint *ConstraintPositioningViewV(VIEW_CLASS *view, CGFloat y)
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1 constant:y];
    return constraint;
}

NSArray *ConstraintsPositioningView(VIEW_CLASS *view, CGPoint point)
{
    return @[
             ConstraintPositioningViewH(view, point.x),
             ConstraintPositioningViewV(view, point.y),
             ];
}

void PositionView(VIEW_CLASS *view, CGPoint point, NSUInteger priority)
{
    NSArray *constraints = ConstraintsPositioningView(view, point);
    InstallConstraints(constraints, priority, @"Position");
}

void Pin(VIEW_CLASS *view, NSString *format)
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:@{@"view":view}];
    InstallConstraints(constraints, LayoutPriorityRequired, nil);
}

void PinWithPriority(VIEW_CLASS *view, NSString *format, NSString *name, int priority)
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:@{@"view":view}];
    InstallConstraints(constraints, priority, name);
}

#pragma mark - Contrast View

void LoadContrastViewsOntoView(VIEW_CLASS *aView)
{
    // Create a pair of contrast views to highlight placement
    VIEW_CLASS *contrastView;
    COLOR_CLASS *bgColor = [[COLOR_CLASS lightGrayColor] colorWithAlphaComponent:0.3f];
    NSLayoutConstraint *constraint;
    
    // First, cover left half of the parent
    contrastView = [[VIEW_CLASS alloc] init];
    contrastView.nametag = @"Contrast View Vertical";
    contrastView.backgroundColor = bgColor;
    [aView addSubview:contrastView];
    contrastView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Stretch vertically and pin left
    StretchVerticallyToSuperview(contrastView, 0, LayoutPriorityRequired);
    AlignView(contrastView, NSLayoutAttributeLeft, 0, LayoutPriorityRequired);
    
    // Constrain width to half of parent
    constraint = [NSLayoutConstraint constraintWithItem:contrastView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:aView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.0f];
    [constraint install];
    
    // Then cover bottom half of parent
    contrastView = [[VIEW_CLASS alloc] init];
    contrastView.nametag = @"Contrast View Horizontal";
    contrastView.backgroundColor = bgColor;
    [aView addSubview:contrastView];
    contrastView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Stretch horizontally and pin bottom
    StretchHorizontallyToSuperview(contrastView, 0, LayoutPriorityRequired);
    AlignView(contrastView, NSLayoutAttributeBottom, 0, LayoutPriorityRequired);
    
    // Constrain height to half of parent
    constraint = [NSLayoutConstraint constraintWithItem:contrastView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:aView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.0f];
    [constraint install];
}
