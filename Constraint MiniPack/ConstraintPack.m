/*
 
 Erica Sadun, http://ericasadun.com
 
 See iOS Auto Layout Demystified

 */

#import "ConstraintPack.h"

// Return nearest common ancestor between two views
View *NearestCommonViewAncestor(View *view1, View *view2)
{
    if (!view1 || !view2) return nil;
    
    if ([view1 isEqual:view2]) return view1;
    
    // Collect superviews
    View *view;
    NSMutableArray *array1 = [NSMutableArray arrayWithObject:view1];
    view = view1.superview;
    while (view != nil)
    {
        [array1 addObject:view];
        view = view.superview;
    }
    
    NSMutableArray *array2 = [NSMutableArray arrayWithObject:view2];
    view = view2.superview;
    while (view != nil)
    {
        [array2 addObject:view];
        view = view.superview;
    }
    
    // Check for superview relationships
    if ([array1 containsObject:view2]) return view2;
    if ([array2 containsObject:view1]) return view1;
    
    // Check for indirect ancestor
    for (View *view in array1)
        if ([array2 containsObject:view]) return view;
    
    return nil;
}

#pragma mark - NSLayoutConstraint Constraint Pack Category
@implementation NSLayoutConstraint (ConstraintPack)

// Install constraints to their natural target, the nearest common ancestor
- (BOOL) install
{
    View *firstView = (View *) self.firstItem;
    View *secondView = (View *) self.secondItem;
    
    // Handle Unary constraint
    if (!self.secondItem)
    {
        [firstView addConstraint:self];
        return YES;
    }
    
    // Install onto nearest common ancestor
    View *view = NearestCommonViewAncestor(firstView, secondView);
    if (!view)
    {
        NSLog(@"Error: Constraint cannot be installed. No common ancestor between items.");
        return NO;
    }
    
    [view addConstraint:self];
    return YES;
}

- (BOOL) installWithPriority: (float) priority
{
    self.priority = priority;
    return [self install];
}

// Remove constraints from their natural target
- (void) remove
{
    if (![self.class isEqual:[NSLayoutConstraint class]])
    {
        NSLog(@"Error: Can only uninstall NSLayoutConstraint. %@ is an invalid class.", self.class.description);
        return;
    }
    
    if (self.secondItem == nil)
    {
        View *view = (View *) self.firstItem;
        [view removeConstraint:self];
        return;
    }
    
    // Remove from preferred recipient
    View *view = NearestCommonViewAncestor((View *) self.firstItem, (View *) self.secondItem);
    if (!view) return;
    
    // If the constraint not on view, this is a no-op
    [view removeConstraint:self];
}

// Test constraint against view
- (BOOL) refersToView: (View *) theView
{
    if (!theView)
        return NO;
    if (!self.firstItem) // shouldn't happen. Illegal
        return NO;
    if (self.firstItem == theView)
        return YES;
    if (!self.secondItem)
        return NO;
    return (self.secondItem == theView);
}
@end

#pragma mark - Installation

// Install constraint array
void InstallConstraints(NSArray *constraints, NSUInteger priority)
{
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (![constraint isKindOfClass:[NSLayoutConstraint class]])
            continue;
        if (priority)
            [constraint installWithPriority:priority];
        else
            [constraint install];
    }
}

// Remove constraint array
void RemoveConstraints(NSArray *constraints)
{
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (![constraint isKindOfClass:[NSLayoutConstraint class]])
            continue;
        [constraint remove];
    }
}

#pragma mark - References

// Positioning constraints
NSArray *ExternalConstraintsReferencingView(View *view)
{
    if (!view) return @[];
    
    NSMutableArray *superviews = [NSMutableArray array];
    View *superview = view.superview;
    while (superview != nil)
    {
        [superviews addObject:superview];
        superview = superview.superview;
    }
    
    NSMutableArray *constraints = [NSMutableArray array];
    for (View *superview in superviews)
        for (NSLayoutConstraint *constraint in superview.constraints)
        {
            if (![constraint.class isEqual:[NSLayoutConstraint class]])
                continue;
            
            if ([constraint refersToView:view])
                [constraints addObject:constraint];
        }
    
    return constraints.copy;
}

// Sizing constraints
NSArray *InternalConstraintsReferencingView(View *view)
{
    if (!view) return @[];
    
    NSMutableArray *constraints = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in view.constraints)
    {
        if (![constraint.class isEqual:[NSLayoutConstraint class]])
            continue;
        
        if ([constraint refersToView:view])
            [constraints addObject:constraint];
    }
    
    return constraints.copy;
}

// All constraints referencing view
NSArray *ConstraintsReferencingView(View *view)
{
    if (!view) return @[];
    
    NSArray *internal = InternalConstraintsReferencingView(view);
    NSArray *external = ExternalConstraintsReferencingView(view);
    return [internal arrayByAddingObjectsFromArray:external];
}

@implementation View (ConstraintPack)
// Positioning constraints
- (NSArray *) externalConstraintReferences
{
    return ExternalConstraintsReferencingView(self);
}

// Sizing constraints
- (NSArray *) internalConstraintReferences
{
    return InternalConstraintsReferencingView(self);
}

// All constraints referencing view
- (NSArray *) constraintReferences
{
    return ConstraintsReferencingView(self);
}

- (View *) nearestCommonAncestorWithView: (View *) view
{
    return NearestCommonViewAncestor(self, view);
}

- (BOOL) autoLayoutEnabled
{
    return !self.translatesAutoresizingMaskIntoConstraints;
}

- (void) setAutoLayoutEnabled:(BOOL)autoLayoutEnabled
{
    self.translatesAutoresizingMaskIntoConstraints = !autoLayoutEnabled;
}
@end

#pragma mark - Format Installation
void InstallLayoutFormats(NSArray *formats, NSLayoutFormatOptions options, NSDictionary *metrics, NSDictionary *bindings, NSUInteger priority)
{
    for (NSString *format in formats)
    {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:options metrics:metrics views:bindings];
        InstallConstraints(constraints, priority);
    }
}


#pragma mark - Debugging
// Keep view within superview, usually apply with 1 priority
void ConstrainViewToSuperview(View *view, CGFloat inset, NSUInteger priority)
{
    if (!view || !view.superview) return;
    NSArray *formats = @[
                         @"H:|->=inset-[view]",
                         @"H:[view]->=inset-|",
                         @"V:|->=inset-[view]",
                         @"V:[view]->=inset-|"];
    InstallLayoutFormats(formats, 0, @{@"inset":@(inset)}, @{@"view":view}, priority);
}

#pragma mark - Single View Layout
void ConstrainMinimumViewSize(View *view, CGSize size,  NSUInteger  priority)
{
    if (!view) return;
    
    NSDictionary *metrics = @{@"width":@(size.width), @"height":@(size.height)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    
    NSMutableArray *formats = [NSMutableArray array];
    if (size.width != SkipConstraint)
        [formats addObject:@"H:[view(>=width)]"];
    if (size.height != SkipConstraint)
        [formats addObject:@"V:[view(>=height)]"];
    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

void ConstrainMaximumViewSize(View *view, CGSize size,  NSUInteger  priority)
{
    if (!view) return;
    
    NSDictionary *metrics = @{@"width":@(size.width), @"height":@(size.height)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    
    NSMutableArray *formats = [NSMutableArray array];
    if (size.width != SkipConstraint)
        [formats addObject:@"H:[view(<=width)]"];
    if (size.height != SkipConstraint)
        [formats addObject:@"V:[view(<=height)]"];
    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

void SizeView(View *view, CGSize size, NSUInteger  priority)
{
    if (!view) return;
    
    NSDictionary *metrics = @{@"width":@(size.width), @"height":@(size.height)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    
    NSMutableArray *formats = [NSMutableArray array];
    if (size.width != SkipConstraint)
        [formats addObject:@"H:[view(==width)]"];
    if (size.height != SkipConstraint)
        [formats addObject:@"V:[view(==height)]"];
    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

void PositionView(View *view, CGPoint point, NSUInteger priority)
{
    if (!view || !view.superview)
        return;
    NSDictionary *metrics = @{@"hLoc":@(point.x), @"vLoc":@(point.y)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    
    NSMutableArray *formats = [NSMutableArray array];
    if (point.x != SkipConstraint)
        [formats addObject:@"H:|-hLoc-[view]"];
    if (point.y != SkipConstraint)
        [formats addObject:@"V:|-vLoc-[view]"];
    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

void StretchViewHorizontallyToSuperview(View *view, CGFloat inset, NSUInteger priority)
{
    if (!view || !view.superview) return;

    NSDictionary *metrics = @{@"inset":@(inset)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSArray *formats = @[@"H:|-inset-[view]-inset-|"];

    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

void StretchViewVerticallyToSuperview(View *view, CGFloat inset, NSUInteger priority)
{
    if (!view || !view.superview) return;
    
    NSDictionary *metrics = @{@"inset":@(inset)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSArray *formats = @[@"V:|-inset-[view]-inset-|"];
    
    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

// Use SkipConstraint field to omit a stretch
void StretchViewToSuperview(View *view, CGSize inset, NSUInteger priority)
{
    if (!view || !view.superview) return;

    if (inset.width != SkipConstraint)
        StretchViewHorizontallyToSuperview(view, inset.width, priority);
    if (inset.height != SkipConstraint)
        StretchViewVerticallyToSuperview(view, inset.height, priority);
}

// Aligns view along Left, Leading, Right, Trailing, Top, Bottom
// Unsupported attributes are Width, Height, Baseline, NotAnAttribute, CenterX, CenterY
void AlignViewInSuperview(View *view, NSLayoutAttribute attribute, NSInteger inset, NSUInteger priority)
{
    if (!view || !view.superview) return;
    if ([@[@(NSLayoutAttributeBaseline), @(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight), @(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY), @(NSLayoutAttributeNotAnAttribute)] containsObject:@(attribute)])
        return; // Not supported
    
    if ([@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeTop), @(NSLayoutAttributeLeading)] containsObject:@(attribute)])
        inset = inset * -1;
        
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view.superview  attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view attribute:attribute multiplier:1 constant:inset];
    [constraint installWithPriority:priority];
}

#pragma mark - View to View Layout
void AlignViews(NSUInteger priority, View *view1, View *view2, NSLayoutAttribute attribute)
{
    if (!view1 || !view2) return;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1 attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attribute multiplier:1 constant:0];
    [constraint installWithPriority:priority];
}

void CenterViewInSuperview(View *view, BOOL horizontal, BOOL vertical, NSUInteger priority)
{
    if (!view || !view.superview) return;
    
    if (horizontal)
        AlignViews(priority, view, view.superview, NSLayoutAttributeCenterX);
    if (vertical)
        AlignViews(priority, view, view.superview, NSLayoutAttributeCenterY);
}

#pragma mark - Visual Formats
// View is named view
void ConstrainView(NSString *formatString, View *view, NSUInteger priority)
{
    if (!view) return;
    
    InstallLayoutFormats(@[formatString], 0, nil, NSDictionaryOfVariableBindings(view), priority);
}

// Views are named view1, view2
void ConstrainViewPair(NSString *formatString, View *view1, View *view2, NSUInteger priority)
{
    if (!view1 || !view2) return;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view1, view2);
    InstallLayoutFormats(@[formatString], 0, nil, bindings, priority);
}

// Views are named view1, view2, view3...
void ConstrainViewArray(NSUInteger priority, NSString *formatString, NSArray *viewArray)
{
    if (!viewArray || (viewArray.count == 0)) return;
    
    int i = 1;
    NSMutableDictionary *bindings = [NSMutableDictionary dictionary];
    for (View *view in viewArray)
    {
        NSString *name = [NSString stringWithFormat:@"view%d", i++];
        bindings[name] = view;
    }

    InstallLayoutFormats(@[formatString], 0, nil, bindings, priority);
}

void ConstrainViewsWithBinding(NSUInteger priority, NSString *formatString, NSDictionary *bindings)
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:bindings];
    InstallConstraints(constraints, priority);
}

#pragma mark - Layout Guides
#if TARGET_OS_IPHONE
void StretchViewToController(UIViewController *controller, View *view, CGSize inset, NSUInteger priority)
{
    id topGuide = controller.topLayoutGuide;
    id bottomGuide = controller.bottomLayoutGuide;

    NSDictionary *metrics = @{@"hinset":@(inset.width), @"vinset":@(inset.height)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view, topGuide, bottomGuide);
    NSArray *formats = @[@"V:[topGuide]-vinset-[view]-vinset-[bottomGuide]", @"H:|-hinset-[view]-hinset-|"];
    
    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

void StretchViewToTopLayoutGuide(UIViewController *controller, View *view, NSInteger inset, NSUInteger priority)
{
    if (!controller || !view) return;
    
    id topGuide = controller.topLayoutGuide;
    
    NSDictionary *metrics = @{@"inset":@(inset)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view, topGuide);
    NSArray *formats = @[@"V:[topGuide]-inset-[view]"];
    
    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

void StretchViewToBottomLayoutGuide(UIViewController *controller, View *view, NSInteger inset, NSUInteger priority)
{
    if (!controller || !view) return;
    
    id bottomGuide = controller.bottomLayoutGuide;
    
    NSDictionary *metrics = @{@"inset":@(inset)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view, bottomGuide);
    NSArray *formats = @[@"V:[view]-inset-[bottomGuide]"];
    
    InstallLayoutFormats(formats, 0, metrics, bindings, priority);
}

@implementation UIViewController (ExtendedLayouts)
- (BOOL) extendLayoutUnderBars
{
    return (self.edgesForExtendedLayout == UIRectEdgeNone);
}

- (void) setExtendLayoutUnderBars:(BOOL)extendLayoutUnderBars
{
    if (extendLayoutUnderBars)
        self.edgesForExtendedLayout = UIRectEdgeAll;
    else
        self.edgesForExtendedLayout = UIRectEdgeNone;
}
@end
#endif


#pragma mark - Content Size
void SetHuggingPriority(View *view, NSUInteger priority)
{
    if (!view) return;
    
    for (int axis = 0; axis <= 1; axis++)
#if TARGET_OS_IPHONE
        [view setContentHuggingPriority:priority forAxis:axis];
#elif TARGET_OS_MAC
        [view setContentHuggingPriority:priority forOrientation:axis];
#endif
}

void SetResistancePriority(View *view, NSUInteger priority)
{
    if (!view) return;

    for (int axis = 0; axis <= 1; axis++)
#if TARGET_OS_IPHONE
        [view setContentCompressionResistancePriority:priority forAxis:axis];
#elif TARGET_OS_MAC
        [view setContentCompressionResistancePriority:priority forOrientation:axis];
#endif
}

#pragma mark - Integration

#if TARGET_OS_IPHONE
void LayoutThenCleanup(View *view, void(^layoutBlock)())
{
    if (layoutBlock) layoutBlock();
    [view layoutIfNeeded];
    if (view.superview)
        [view.superview layoutIfNeeded];
    RemoveConstraints(view.externalConstraintReferences);
}
#endif