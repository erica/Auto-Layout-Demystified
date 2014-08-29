/*
 
 Erica Sadun, http://ericasadun.com
 
 See iOS Auto Layout Demystified

 */

#import "ConstraintPack.h"
#if TARGET_OS_IPHONE
    #define View UIView
    #define Color UIColor
    #define Image UIImage
    #define Font UIFont
#elif TARGET_OS_MAC
    #define View NSView
    #define Color NSColor
    #define Image NSImage
    #define Font NSFont
#endif

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

// For iOS 8 and later, you can simply set a constraint's active property to YES and it will self-install. Set active to NO and it uninstalls.

#pragma mark - NSLayoutConstraint Constraint Pack Category
@implementation NSLayoutConstraint (ConstraintPack)

// Install constraints to their natural target, the nearest common ancestor
- (BOOL) install
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
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
#else
    self.active = YES;
    return YES;
#endif
}

- (BOOL) installWithPriority: (float) priority
{
    self.priority = priority;
    return [self install];
}

// Remove constraints from their natural target
- (void) remove
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
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
#else
    self.active = NO;
#endif
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

- (void) dumpViewReportAtIndent: (int) indent
{
    printf("\n");
    for (int i = 0; i < indent * 4; i++) printf("-");
    printf("[%s:%0x]", self.class.description.UTF8String, (unsigned int) self);
    if (self.tag != 0)
        printf(" (tag:%0zd)", self.tag);
    printf(" [%0.1f, %0.1f, %0.1f, %0.1f]", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    printf(" constraints: %zd stored, %zd references", self.constraints.count, self.constraintReferences.count);
    printf("\n");
    
    for (NSLayoutConstraint *c in self.constraintReferences)
    {
        for (int i = 0; i < indent * 4; i++) printf("-");
        printf("* %s (%zd)\n", c.debugDescription.UTF8String, c.priority);
    }
    
    for (View *view in self.subviews)
        [view dumpViewReportAtIndent:indent + 1];
}

- (void) dumpViewReport
{
    [self dumpViewReportAtIndent:0];
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
    if ([@[@(NSLayoutAttributeBaseline), @(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight), @(NSLayoutAttributeNotAnAttribute)] containsObject:@(attribute)])
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

// Guides are back to top and bottom. Left and right are dropped. New attributes are left, right, top, bottom, leading, trailing margins and x/y centers within margins

void StretchViewToController(UIViewController *controller, View *view, CGSize inset, NSUInteger priority)
{
    StretchViewHorizontallyToSuperview(view, inset.width, priority);
    StretchViewToTopLayoutGuide(controller, view, inset.height, priority);
    StretchViewToBottomLayoutGuide(controller, view, inset.height, priority);
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

#pragma mark Placement

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

// Place view: tl, tc, tr
//             cl  cc  cr
//             bl  bc  br
// use xx for stretch
// use -- to skip vertical or horizontal

void PlaceViewInSuperview(View *view, NSString *position, CGFloat inseth, CGFloat insetv, CGFloat priority)
{
    if (!position) return;
    if (position.length != 2) return;
    
    if (!view.superview) return;
    
    // Participate in Auto Layout
    view.autoLayoutEnabled = YES;
    
    NSString *verticalPosition = [position substringToIndex:1];
    NSString *horizontalPosition = [position substringFromIndex:1];
    void (^block)();
    
    NSDictionary *actionDictionary =
    @{
      @"t" : ^{AlignViewInSuperview(view, NSLayoutAttributeTop, insetv, priority);},
      @"c" : ^{AlignViewInSuperview(view, NSLayoutAttributeCenterY, insetv, priority);},
      @"b" : ^{AlignViewInSuperview(view, NSLayoutAttributeBottom, insetv, priority);},
      @"x" : ^{StretchViewVerticallyToSuperview(view, insetv, priority);}
      };
    if ((block = actionDictionary[verticalPosition])) block();
    
    actionDictionary =
    @{
      @"l" : ^{AlignViewInSuperview(view, NSLayoutAttributeLeading, inseth, priority);},
      @"c" : ^{AlignViewInSuperview(view, NSLayoutAttributeCenterX, inseth, priority);},
      @"r" : ^{AlignViewInSuperview(view, NSLayoutAttributeTrailing, inseth, priority);},
      @"x" : ^{StretchViewHorizontallyToSuperview(view, inseth, priority);}
      };
    if ((block = actionDictionary[horizontalPosition])) block();
}

#if TARGET_OS_IPHONE
void PlaceView(UIViewController *controller, UIView *view, NSString *position, CGFloat inseth, CGFloat insetv, CGFloat priority)
{
    if (!position) return;
    if (position.length != 2) return;

    // Place if not already placed
    if (!view.superview)
        [controller.view addSubview:view];
    
    // Participate in Auto Layout
    view.autoLayoutEnabled = YES;
    
    NSString *verticalPosition = [position substringToIndex:1];
    NSString *horizontalPosition = [position substringFromIndex:1];
    
    // Handle stretches with respect to view controller
    if ([position hasPrefix:@"x"])
    {
        StretchViewToTopLayoutGuide(controller, view, insetv, priority);
        StretchViewToBottomLayoutGuide(controller, view, inseth, priority);
        verticalPosition = @"-";
    }
    
    if ([position hasSuffix:@"x"])
    {
        // Edge to edge. Skips left and right guides as they are inset
        StretchViewHorizontallyToSuperview(view, inseth, priority);
        horizontalPosition = @"-";
    }
    
    // Otherwise place
    PlaceViewInSuperview(view, [NSString stringWithFormat:@"%@%@", verticalPosition, horizontalPosition], inseth, insetv, priority);
}
#endif

#define TrimString(_string_) ([_string_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])

void AddConstraint(NSString *request, View *view1, View * view2, CGFloat m, CGFloat c, NSInteger priority)
{
    NSArray *components = @[];
    for (NSString *separator in @[@".", @" "])
    {
        components = [request componentsSeparatedByString:separator];
        if (components.count == 3) break;
    }

    if (components.count != 3)
    {
        for (NSString *separator in @[@"<=", @"==", @">=", @"<", @"=", @">"])
        {
            components = [request componentsSeparatedByString:separator];
            if (components.count == 2)
            {
                components = @[components[0], separator, components[1]];
                break;
            }
        }
    }
    
    if (components.count != 3)
    {
        NSLog(@"AddConstraint format error: %@", request);
        return;
    }
    
    NSString *firstAttributeString = TrimString(components[0]).lowercaseString;
    NSString *secondAttributeString = TrimString(components[2]).lowercaseString;
    NSString *relationString = [TrimString(components[1]) substringWithRange:NSMakeRange(0, 1)].lowercaseString;
    
    NSDictionary *attributes = @{
                                 @"left":@(NSLayoutAttributeLeft),
                                 @"right":@(NSLayoutAttributeRight),
                                 @"top":@(NSLayoutAttributeTop),
                                 @"bottom":@(NSLayoutAttributeBottom),
                                 @"leading":@(NSLayoutAttributeLeading),
                                 @"trailing":@(NSLayoutAttributeTrailing),
                                 @"width":@(NSLayoutAttributeWidth),
                                 @"height":@(NSLayoutAttributeHeight),
                                 @"centerx":@(NSLayoutAttributeCenterX),
                                 @"centery":@(NSLayoutAttributeCenterY),
                                 
#if TARGET_OS_IPHONE && (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000)
                                 @"leftmargin":@(NSLayoutAttributeLeftMargin),
                                 @"rightmargin":@(NSLayoutAttributeRightMargin),
                                 @"topmargin":@(NSLayoutAttributeTopMargin),
                                 @"bottommargin":@(NSLayoutAttributeBottomMargin),
                                 @"leadingmargin":@(NSLayoutAttributeLeadingMargin),
                                 @"trailingmargin":@(NSLayoutAttributeTrailingMargin),
                                 @"centerxmargin":@(NSLayoutAttributeCenterXWithinMargins),
                                 @"centerymargin":@(NSLayoutAttributeCenterYWithinMargins),
#endif
                                 @"baseline":@(NSLayoutAttributeBaseline),
#if TARGET_OS_IPHONE && (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000)
                                 @"firstbaseline":@(NSLayoutAttributeFirstBaseline),
                                 @"lastbaseline":@(NSLayoutAttributeLastBaseline),
#endif
                                 @"notanattribute":@(NSLayoutAttributeNotAnAttribute),
                                 @"_":@(NSLayoutAttributeNotAnAttribute),
                                 @"_naa_":@(NSLayoutAttributeNotAnAttribute),
                                 @"skip":@(NSLayoutAttributeNotAnAttribute),
                                 };
    
    NSDictionary *relations = @{@"<":@(NSLayoutRelationLessThanOrEqual),
                                @"=":@(NSLayoutRelationEqual),
                                @">":@(NSLayoutRelationGreaterThanOrEqual)};
    
    NSLayoutAttribute firstAttribute = [attributes[firstAttributeString] integerValue];
    NSLayoutAttribute secondAttribute = [attributes[secondAttributeString] integerValue];
    NSLayoutRelation relation = [relations[relationString] integerValue];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:view1
                                      attribute:firstAttribute
                                      relatedBy:relation
                                      toItem:view2
                                      attribute:secondAttribute
                                      multiplier:m
                                      constant:c];
    [constraint installWithPriority:priority];
}

#undef TrimString

// Cleanup
#undef View
#undef Color
#undef Image
#undef Font