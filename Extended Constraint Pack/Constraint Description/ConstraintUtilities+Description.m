/*
 
 Erica Sadun, http://ericasadun.com
 
 Thanks for formatting suggestions to Lyle Andrews
 */

#import "View+Description.h"
#import "ConstraintUtilities+Description.h"

#if TARGET_OS_IPHONE
#define View UIView
#elif TARGET_OS_MAC
#define View NSView
#endif

#ifndef UIViewNoIntrinsicMetric
#define UIViewNoIntrinsicMetric -1
#endif

#pragma mark - Constraint Description
@implementation NSLayoutConstraint (StringDescription)

// Transform the attribute to a string
+ (NSString *) nameForLayoutAttribute: (NSLayoutAttribute) anAttribute
{
    switch (anAttribute)
    {
        case NSLayoutAttributeLeft: return @"left";
        case NSLayoutAttributeRight: return @"right";
        case NSLayoutAttributeTop: return @"top";
        case NSLayoutAttributeBottom: return @"bottom";
        case NSLayoutAttributeLeading: return @"leading";
        case NSLayoutAttributeTrailing: return @"trailing";
        case NSLayoutAttributeWidth: return @"width";
        case NSLayoutAttributeHeight: return @"height";
        case NSLayoutAttributeCenterX: return @"centerX";
        case NSLayoutAttributeCenterY: return @"centerY";
        case NSLayoutAttributeBaseline: return @"baseline";
        case NSLayoutAttributeNotAnAttribute:
        default: return @"not-an-attribute";
    }
}

// Transform the attribute to a string
+ (NSString *) nameForFormatOption:(NSLayoutFormatOptions)anOption
{
    NSLayoutFormatOptions option = anOption & NSLayoutFormatAlignmentMask;    
    switch (option)
    {
        case NSLayoutFormatAlignAllLeft: return @"Left Alignment";
        case NSLayoutFormatAlignAllRight: return @"Right Alignment";
        case NSLayoutFormatAlignAllTop: return @"Top Alignment";
        case NSLayoutFormatAlignAllBottom: return @"Bottom Alignment";
        case NSLayoutFormatAlignAllLeading: return @"Leading Alignment";
        case NSLayoutFormatAlignAllTrailing: return @"Trailing Alignment";
        case NSLayoutFormatAlignAllCenterX: return @"CenterX Alignment";
        case NSLayoutFormatAlignAllCenterY: return @"CenterY Alignment";
        case NSLayoutFormatAlignAllBaseline: return @"Baseline Alignment";
        default:
            break;
    }
    
    option = anOption & NSLayoutFormatDirectionMask;
    switch (option)
    {
        case NSLayoutFormatDirectionLeadingToTrailing:
            return @"Leading to Trailing";
        case NSLayoutFormatDirectionLeftToRight:
            return @"Left to Right";
        case NSLayoutFormatDirectionRightToLeft:
            return @"Right to Left";
        default:
            return @"Unknown Format Option";
    }
}


// Transform the relation to a string
+ (NSString *) nameForLayoutRelation: (NSLayoutRelation) aRelation
{
    switch (aRelation)
    {
        case NSLayoutRelationLessThanOrEqual: return @"<=";
        case NSLayoutRelationEqual: return @"==";
        case NSLayoutRelationGreaterThanOrEqual: return @">=";
        default: return @"not-a-relation";
    }
}

- (ConstraintSourceType) sourceType
{
    ConstraintSourceType result = ConstraintSourceTypeCustom;
    if (self.shouldBeArchived)
    {
        result = ConstraintSourceTypeSatisfaction;
        NSString *description = self.debugDescription;
        if ([description rangeOfString:@"ambiguity"].location != NSNotFound)
            result = ConstraintSourceTypeDisambiguation;
        else if ([description rangeOfString:@"fixed frame"].location != NSNotFound)
            result = ConstraintSourceTypeInferred;
    }
    return result;
}

// Represent the constraint as a string
- (NSString *) stringValue
{
    if (!self.firstItem)
        return nil;
    
    // Establish firstView.firstAttribute
    NSString *firstViewString = [(View *)self.firstItem objectIdentifier];
    NSString *firstAttribute = [NSLayoutConstraint nameForLayoutAttribute:self.firstAttribute];
    NSString *firstString = [NSString stringWithFormat:@"<%@>.%@", firstViewString, firstAttribute];
    
    // Relation
    NSString *relationString =  [NSLayoutConstraint nameForLayoutRelation:self.relation];
    
    // Handle Unary Constraints
    if (self.secondItem == nil)
        return [NSString stringWithFormat:@"%@ %@ %0.01f", firstString, relationString, self.constant];
    
    // Establish secondView.secondAttribute
    NSString *secondViewString = [(View *)self.secondItem objectIdentifier];
    NSString *secondAttribute = [NSLayoutConstraint nameForLayoutAttribute:self.secondAttribute];
    NSString *secondString = [NSString stringWithFormat:@"<%@>.%@", secondViewString, secondAttribute];
    
    // Initialize right hand side string
    NSString *rhsRepresentation = secondString;
    
    // Add multiplier
    if (self.multiplier != 1.0f)
        rhsRepresentation = [NSString stringWithFormat:@"%@ * %0.1f", rhsRepresentation, self.multiplier];

    // Initialize constant
    NSString *constantString = @"";
    
    // Positive constant
    if (self.constant > 0.0f)
        constantString = [NSString stringWithFormat:@"+ %0.1f", self.constant];
    
    // Negative constant
    if (self.constant < 0.0f)
        constantString = [NSString stringWithFormat:@"- %0.1f", fabs(self.constant)];
    
    // Add constant
    if (self.constant != 0.0f)
        rhsRepresentation = [NSString stringWithFormat:@"%@ %@", rhsRepresentation, constantString];
    
    // Note source
    NSString *interfaceBuilderString = @"";
    switch (self.sourceType)
    {
        case ConstraintSourceTypeInferred:
            interfaceBuilderString = @"\n         ** Added by IB (inferred position)";
            break;
        case ConstraintSourceTypeDisambiguation:
            interfaceBuilderString = @"\n         ** Added by IB (ambiguity resolution)";
            break;
        case ConstraintSourceTypeSatisfaction:
            interfaceBuilderString = @"\n         ** Added in IB";
            break;
        case ConstraintSourceTypeCustom:
        case ConstraintSourceTypeUnknown:
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@%@", firstString, relationString, rhsRepresentation, interfaceBuilderString];
}
@end

#pragma mark - Constraint View Utility
@implementation View (ConstraintUtility)
// Apple-style frame description
- (NSString *) readableFrame
{
    return ReadableRect(self.frame);
}

// Ditto alignment rect
- (NSString *) readableAlignmentRect
{
    return ReadableRect([self alignmentRectForFrame:self.frame]);
}

- (NSString *) readableAlignmentInsets
{
    return ReadableInsets(self.alignmentRectInsets);
}

// Return an array of all superviews
- (NSArray *) superviews
{
    NSMutableArray *array = [NSMutableArray array];
    View *view = self.superview;
    while (view)
    {
        [array addObject:view];
        view = view.superview;
    }
    
    return array;
}

// Tests view against superviews
- (BOOL) isAncestorOfView: (View *) aView
{
    return [aView.superviews containsObject:self];
}

// Return all constraints from self and subviews
// Call on self.window for the entire collection
- (NSArray *) allConstraints
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.constraints];
    for (View *view in self.subviews)
        [array addObjectsFromArray:[view allConstraints]];
    return array;
}
@end

#pragma mark - Format Description

#define IsLeadingAttribute(_ATTRIBUTE_) [@[@(NSLayoutAttributeTop), @(NSLayoutAttributeLeading), @(NSLayoutAttributeLeft)] containsObject:@(_ATTRIBUTE_)]
#define IsTrailingAttribute(_ATTRIBUTE_) [@[@(NSLayoutAttributeBottom), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeRight)] containsObject:@(_ATTRIBUTE_)]
#define IsUnsupportedAttribute(_ATTRIBUTE_) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeBaseline)] containsObject:@(_ATTRIBUTE_)]

@implementation NSLayoutConstraint (FormatDescription)

// Where possible, transform constraint to visual format
- (NSString *) visualFormat
{
    View *firstView = (View *) self.firstItem;
    View *secondView = (View *) self.secondItem;
    
    // I've skipped priorities for these, although that's easily added
    NSString *item1 = firstView.objectIdentifier;
    NSString *item2 = secondView.objectIdentifier;
    NSString *relation = [NSLayoutConstraint nameForLayoutRelation:self.relation];
    
    // Don't show == relations
    if ([relation isEqualToString:@"=="])
        relation = @"";
    
    // Key for layout direction
    NSString *hOrV = IsHorizontalAttribute(self.firstAttribute) ? @"H:" : @"V:";

    // Superview relationships
    BOOL secondViewIsSuperview = (firstView.superview == secondView);
    BOOL firstViewIsSuperview = (secondView.superview == firstView);
    
    // Center is not supported, but I've added a little tweak here
    if (self.firstItem && self.secondItem &&
        IsCenterAttribute(self.firstAttribute) &&
        IsCenterAttribute(self.secondAttribute))
    {
        // Check for unsupported conditions
        if (self.multiplier != 1.0f) return nil;
        if (self.constant != 0.0f) return nil;
        if (self.relation != NSLayoutRelationEqual) return nil;

        // a little fun extension
        if (firstViewIsSuperview)
            return [NSString stringWithFormat:@"%@|~<%@>~|", hOrV, item2];        
        else if (secondViewIsSuperview)
            return [NSString stringWithFormat:@"%@|~<%@>~|", hOrV, item1]; 
        
        return [NSString stringWithFormat:@"%@~[<%@>,<%@>]~", hOrV, item1, item2];
        // return nil;
    }
    
    // Center is not supported
    if (IsCenterAttribute(self.firstAttribute))
        return nil;
    if (IsCenterAttribute(self.secondAttribute))
        return nil;    
    
    // Valid constraints are either size constraints or edge constraints
    // and never the twain shall meet.
    
    // Size constraint
    if (IsSizeAttribute(self.firstAttribute))
    {
        // Handle unary size case
        if (self.secondItem == nil)
        {
            return [NSString stringWithFormat:@"%@[%@(%@%d)]", hOrV, item1, relation, (int) self.constant];
        }
        
        // Attributes have to match for 2-items w/ visual format
        // even if they make sense for aspect. Easy to add to standard
        if (self.firstAttribute != self.secondAttribute)
            return nil;
        
        // Match item to item. I've gone ahead and extended this
        // to multiplier and constant. This is non-standard
        NSMutableString *result = [NSMutableString string];
        [result appendFormat:@"%@[%@(%@<%@>", hOrV, item2, relation, item1];
        
        if (self.multiplier != 1.0f)
            [result appendFormat:@" * %0.1f", self.multiplier];
        
        if (self.constant != 0.0f)
            [result appendFormat:@" %@ %0.1f", (self.constant < 0) ? @"-" : @"+", self.constant];
        
        [result appendString:@")]"];
        return result;
    }
    
    // Must not be unary, that case is already handled -- size only
    if (self.secondItem == nil)
        return nil;
    
    // Edge constraint -- supported is top/bottom, leading/trailing
    // Other edges are not visual format standard.
    // Could extend this to LTR: vs H:
    
    // Toss away baseline refs
    if (self.firstAttribute == NSLayoutAttributeBaseline)
        return nil;
    if (self.secondAttribute == NSLayoutAttributeBaseline)
        return nil;

    // For now, expand to LTR
    // if (IsUnsupportedAttribute(self.firstAttribute))
    //    return nil;
    // if (IsUnsupportedAttribute(self.secondAttribute))
    //    return nil;

    // Add support for left and right attributes
    if (IsUnsupportedAttribute(self.firstAttribute) || IsUnsupportedAttribute(self.secondAttribute))
        hOrV = @"LTR:";
    
    // Directions must match -- Illegal otherwise except for a few
    // oddball cases, which I'm skipping such as aspect. They aren't
    // supported by visual constraints
    if (IsVerticalAttribute(self.firstAttribute) != IsVerticalAttribute(self.secondAttribute))
        return nil;
    
    // Must have common ancestor. Illegal otherwise
    if (!([firstView nearestCommonAncestorWithView:secondView]))
        return nil;
    
    // Odd multipliers not supported -- although easily added for odd cases
    // but not by current visual constraints.
    if (self.multiplier != 1.0f)
        return nil;
    
    // Handle superview - subview relations
    if (secondViewIsSuperview || firstViewIsSuperview)
    {
        // Mixed edges not supported
        if (self.firstAttribute != self.secondAttribute)
            return nil;
        
        // Which is the view that's explicitly described?
        NSString *describedView = item2;
        if (secondViewIsSuperview)
            describedView = item1;
        
        // Build the output format
        NSMutableString *result = [NSMutableString string];
        [result appendFormat:@"%@", hOrV];
        
        if (IsLeadingAttribute(self.firstAttribute))
        {
            // Superview at start
            [result appendFormat:@"|-(%@%d)-[%@]", relation, (int) self.constant, describedView];
        }
        else
        {
            // Superview at end
            [result appendFormat:@"[%@]-(%@%d)-|", describedView, relation, (int) self.constant];
        }
        return result;
    }
    
    // Handle leading/trailing and top/bottom pairs,
    // for positive and negative constants
    NSMutableString *result = [NSMutableString string];
    [result appendFormat:@"%@", hOrV];
    
    // [item2]-?-[item1]
    if (IsLeadingAttribute(self.firstAttribute) && IsTrailingAttribute(self.secondAttribute))
    {
        [result appendFormat:@"[%@]-(%@%d)-[%@]", item2, relation, (int) self.constant, item1];
        return result;
    }
    
    // H:[item1]-?-[item2]
    else if (IsTrailingAttribute(self.firstAttribute) && IsLeadingAttribute(self.secondAttribute))
    {
        [result appendFormat:@"[%@]-(%@%d)-[%@]", item1, relation, (int) self.constant, item2];
        return result;
    }
    
    // Anything else is not supported at this time
    return nil;
}
@end

#pragma mark - Code Description

@implementation NSLayoutConstraint (CodeDescription)
// Transform to code string
+ (NSString *) codeNameForLayoutAttribute: (NSLayoutAttribute) anAttribute
{
    switch (anAttribute)
    {
        case NSLayoutAttributeLeft: return @"NSLayoutAttributeLeft";
        case NSLayoutAttributeRight: return @"NSLayoutAttributeRight";
        case NSLayoutAttributeTop: return @"NSLayoutAttributeTop";
        case NSLayoutAttributeBottom: return @"NSLayoutAttributeBottom";
        case NSLayoutAttributeLeading: return @"NSLayoutAttributeLeading";
        case NSLayoutAttributeTrailing: return @"NSLayoutAttributeTrailing";
        case NSLayoutAttributeWidth: return @"NSLayoutAttributeWidth";
        case NSLayoutAttributeHeight: return @"NSLayoutAttributeHeight";
        case NSLayoutAttributeCenterX: return @"NSLayoutAttributeCenterX";
        case NSLayoutAttributeCenterY: return @"NSLayoutAttributeCenterY";
        case NSLayoutAttributeBaseline: return @"NSLayoutAttributeBaseline";
        case NSLayoutAttributeNotAnAttribute:
        default: return @"NSLayoutAttributeNotAnAttribute";
    }
}

// Transform the relation to a code string
+ (NSString *) codeNameForLayoutRelation: (NSLayoutRelation) aRelation
{
    switch (aRelation)
    {
        case NSLayoutRelationLessThanOrEqual: return @"NSLayoutRelationLessThanOrEqual";
        case NSLayoutRelationEqual: return @"NSLayoutRelationEqual";
        case NSLayoutRelationGreaterThanOrEqual: return @"NSLayoutRelationGreaterThanOrEqual";
        default: return @"<Unknown_Relation>";
    }
}

- (NSString *) codeDescriptionWithBindings: (NSDictionary *) dict
{
    View *firstView = (View *) self.firstItem;
    View *secondView = (View *) self.secondItem;

    NSString *firstObject = [[dict allKeysForObject:self.firstItem] lastObject];
    if (!firstObject)
        firstObject = [NSString stringWithFormat:@"<%@>", firstView.objectIdentifier];
    
    // Handle possible unary constraint
    NSString *secondObject = @"";
    if (self.secondItem)
        secondObject = [[dict allKeysForObject:self.secondItem] lastObject];
    if (!secondObject)
        secondObject = [NSString stringWithFormat:@"<%@>", secondView.objectIdentifier];
    
    // Build the description string
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"[NSLayoutConstraint constraintWithItem:%@ attribute:%@ relatedBy:%@ toItem:%@ attribute:%@ multiplier:%f constant:%f];",
     // With book indentation
     // [description appendFormat:@"[NSLayoutConstraint \n    constraintWithItem:%@ attribute:%@ \n    relatedBy:%@ \n    toItem:%@ \n    attribute:%@ \n    multiplier:%f \n    constant:%f];",     
     firstObject,
     [NSLayoutConstraint codeNameForLayoutAttribute:self.firstAttribute],
     [NSLayoutConstraint codeNameForLayoutRelation:self.relation],
     secondObject,
     [NSLayoutConstraint codeNameForLayoutAttribute:self.secondAttribute],
     self.multiplier,
     self.constant
     ];
    return description;
}

- (NSString *) codeDescription
{
    return [self codeDescriptionWithBindings:nil];
}
@end


#pragma mark - Self Explanation

@implementation NSLayoutConstraint (SelfDescription)
#define LIKELY_ILLEGAL  @"Likely Illegal"

// Relate view to itself
- (NSString *) describeSelfConstraint
{
    
    if (!self.firstItem)
        return LIKELY_ILLEGAL;
    
    NSString *comparator = @"";
    if (self.relation == NSLayoutRelationGreaterThanOrEqual)
        comparator = @"Minimum ";
    else if (self.relation == NSLayoutRelationLessThanOrEqual)
        comparator = @"Maximum ";
    
    // Size Constraints
    if (IsSizeAttribute(self.firstAttribute) && IsSizeAttribute(self.secondAttribute))
    {
        if (self.firstAttribute != self.secondAttribute)
            return [NSString stringWithFormat:@"%@View Aspect", comparator];
        return LIKELY_ILLEGAL;
    }
    
    // Center Constraints
    if (IsCenterAttribute(self.firstAttribute) || IsCenterAttribute(self.secondAttribute))
        return LIKELY_ILLEGAL;
    
    // Must be along same plane
    if (IsHorizontalAttribute(self.firstAttribute) != IsHorizontalAttribute(self.secondAttribute))
        return LIKELY_ILLEGAL;
    
    // Edge Constraints
    return [NSString stringWithFormat:@"%@View Size", comparator];
}

// Describe unary
- (NSString *) describeUnaryConstraint
{
    NSString *comparator = @"Exact ";
    if (self.relation == NSLayoutRelationGreaterThanOrEqual)
        comparator = @"Minimum ";
    else if (self.relation == NSLayoutRelationLessThanOrEqual)
        comparator = @"Maximum ";
    
    if ((self.firstAttribute == NSLayoutAttributeWidth) || (self.firstAttribute == NSLayoutAttributeHeight))
        return [NSString stringWithFormat:@"%@Sizing", comparator];
    
    return @"Unary Constraint (Misc)";
}

// Relate two views to each other
- (NSString *) describeSiblingConstraint
{
    NSString *comparator = @"Match ";
    if (self.relation == NSLayoutRelationGreaterThanOrEqual)
        comparator = @"Relate ";
    else if (self.relation == NSLayoutRelationLessThanOrEqual)
        comparator = @"Relate ";
    
    // Must be along same plane
    if (IsHorizontalAttribute(self.firstAttribute) != IsHorizontalAttribute(self.secondAttribute))
        return LIKELY_ILLEGAL;
    
    NSString *first = @"Edge";
    NSString *second = @"Edge";
    if (IsCenterAttribute(self.firstAttribute))
        first = @"Center";
    if (IsSizeAttribute(self.firstAttribute))
        first = @"Size";
    if (IsCenterAttribute(self.secondAttribute))
        second = @"Center";
    if (IsSizeAttribute(self.secondAttribute))
        second = @"Size";
    
    if ([comparator isEqualToString:@"Match "] && [first isEqualToString:second] && [first isEqualToString:@"Edge"])
        return @"View Sequence";
    
    if ([first isEqualToString:second])
        return [NSString stringWithFormat:@"%@%@s", comparator, first];
    
    return [NSString stringWithFormat:@"%@%@ to %@", comparator, first, second];
}

// Relate view to superview
- (NSString *) describeSuperviewBasedConstraint
{
    NSString *comparator = @"Match ";
    if (self.relation == NSLayoutRelationGreaterThanOrEqual)
        comparator = @"Relate ";
    else if (self.relation == NSLayoutRelationLessThanOrEqual)
        comparator = @"Relate ";
    
    NSString *first = @"Edge";
    NSString *second = @"Edge";
    if (IsCenterAttribute(self.firstAttribute))
        first = @"Center";
    if (IsSizeAttribute(self.firstAttribute))
        first = @"Size";
    if (IsCenterAttribute(self.secondAttribute))
        second = @"Center";
    if (IsSizeAttribute(self.secondAttribute))
        second = @"Size";
    
    if ([first isEqualToString:second])
        return [NSString stringWithFormat:@"%@%@ to Superview's %@", comparator, first, first];
    
    View *firstView = (View *) self.firstItem;
    View *secondView = (View *) self.secondItem;
    if ([firstView isAncestorOfView:secondView])
        return [NSString stringWithFormat:@"%@%@ to Superview's %@", comparator, second, first];
    
    return [NSString stringWithFormat:@"%@%@ to Superview's %@", comparator, first, second];
}

// Describe the constraint
- (NSString *) constraintDescription
{
    if (self.secondItem == nil)
        return [self describeUnaryConstraint];
    
    if (self.firstItem == self.secondItem)
        return [self describeSelfConstraint];
    
    View *firstView = (View *) self.firstItem;
    View *secondView = (View *) self.secondItem;

    BOOL superviewRelationship = ([firstView isAncestorOfView:secondView] || [secondView isAncestorOfView:firstView]);
    if (superviewRelationship)
        return [self describeSuperviewBasedConstraint];
    
    return [self describeSiblingConstraint];
}
@end


#pragma mark - View  Description
@implementation View (Description)

#if TARGET_OS_IPHONE
+ (NSString *) nameForContentMode: (UIViewContentMode) mode
{
    switch (mode)
    {
        case UIViewContentModeScaleToFill:
            return @"Scale to Fill";
        case UIViewContentModeScaleAspectFit:
            return @"Scale Aspect Fit";
        case UIViewContentModeScaleAspectFill:
            return @"Scale Aspect Fill";
        case UIViewContentModeRedraw:
            return @"Redraw";
        case UIViewContentModeCenter:
            return @"Center";
        case UIViewContentModeTop:
            return @"Top";
        case UIViewContentModeBottom:
            return @"Bottom:";
        case UIViewContentModeLeft:
            return @"Left";
        case UIViewContentModeRight:
            return @"Right";
        case UIViewContentModeTopLeft:
            return @"Top Left";
        case UIViewContentModeTopRight:
            return @"Top Right";
        case UIViewContentModeBottomLeft:
            return @"Bottom Left";
        case UIViewContentModeBottomRight:
            return @"Bottom Right";
        default:
            return @"Unknown Content Mode";
    }
}
#endif

- (NSString *) superviewsDescription
{
    NSArray *superviews = self.superviews;
    if (superviews.count > 2)
        superviews = [superviews subarrayWithRange:NSMakeRange(0, 2)];
    
    NSMutableString *ancestry = [NSMutableString string];
    [ancestry appendString:self.class.description];
    for (View *view in superviews)
        [ancestry appendFormat:@" : <%@>", view.objectIdentifier];
    if (self.superviews.count > 2)
        [ancestry appendString:@" ..."];
    
    return ancestry;
}

- (NSDictionary *) participatingViews
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[self.objectIdentifier] = self;
    
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        View *firstView = (View *) constraint.firstItem;
        View *secondView = (View *) constraint.secondItem;

        dict[firstView.objectIdentifier] = firstView;
        if (!constraint.secondItem)
            continue;
        dict[secondView.objectIdentifier] = secondView;
    }
    
    return dict;
}

- (NSString *) maskDescription
{
    NSMutableString *string = [NSMutableString string];
    
#if TARGET_OS_IPHONE
    NSDictionary *dict = @{
                           @(UIViewAutoresizingFlexibleLeftMargin): @"LM",
                           @(UIViewAutoresizingFlexibleWidth): @"W",
                           @(UIViewAutoresizingFlexibleRightMargin): @"RM",
                           @(UIViewAutoresizingFlexibleTopMargin): @"TM",
                           @(UIViewAutoresizingFlexibleHeight): @"H",
                           @(UIViewAutoresizingFlexibleBottomMargin): @"BM"
                           };
#elif TARGET_OS_MAC
    NSDictionary *dict = @{
                           @(NSViewMinXMargin): @"LM",
                           @(NSViewWidthSizable): @"W",
                           @(NSViewMaxXMargin): @"RM",
                           @(NSViewMinYMargin): @"TM",
                           @(NSViewHeightSizable): @"H",
                           @(NSViewMaxYMargin): @"BM"
                           };
#endif
    
    for (NSNumber *sizing in dict.allKeys)
    {
        if ((self.autoresizingMask & (sizing.unsignedIntegerValue)) != 0)
            [string appendFormat:@"%@+", dict[sizing]];
    }
    
    if ([string hasSuffix:@"+"])
        [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
    
    return string;
}

- (void) listConstraints
{
    printf("<%s> (%d constraints)\n", self.objectIdentifier.UTF8String, (int) self.constraints.count);
    int i = 1;
    for (NSLayoutConstraint *constraint in self.constraints)
        printf("%2d. @%4d: %s\n", i++, (int) constraint.priority, constraint.stringValue.UTF8String);
    printf("\n");
}

// List constraints for this view and all subviews
- (void) listAllConstraints
{
    [self listConstraints];
    for (View *subview in self.subviews)
        [subview listAllConstraints];
}

// Book examples are less exhaustive
#define BOOK_EXAMPLE    0

// Create view layout description
- (NSString *) viewLayoutDescription
{
    // Create view layout summary
    NSMutableString *description = [NSMutableString string];
    
    // Specify view address, class and superclass
    [description appendFormat:@"<%@>\n  %@ : %@", self.objectIdentifier, self.class.description, self.superclass.description];
    
    // Test for Autosizing and Ambiguous Layout
    if (self.translatesAutoresizingMaskIntoConstraints)
        [description appendFormat:@" [Autoresizes]"];
    if (self.hasAmbiguousLayout)
        [description appendFormat:@" [Caution: Ambiguous Layout!]"];
    [description appendString:@"\n\n"];
    
    // Show description for autoresizing views
    if (self.translatesAutoresizingMaskIntoConstraints && (self.autoresizingMask != 0))
        [description appendFormat:  @"Mask...........%@\n", [self maskDescription]];
    
#if BOOK_EXAMPLE == 0
    // Ancestry
    [description appendFormat:@"Superviews.....%@\n", self.superviewsDescription];
#endif
    
    // Frame and content size
    [description appendFormat:@"Frame:.........%@\n", self.readableFrame];
    
#if TARGET_OS_IPHONE
    if ([self isKindOfClass:[UIScrollView class]])
    {
        [description appendFormat:@"Content size:...%@\n", NSStringFromCGSize([(UIScrollView *)self contentSize])];
        [description appendFormat:@"Content inset:..%@\n", NSStringFromUIEdgeInsets([(UIScrollView *)self contentInset])];
    }
#endif
    
    if (!CGSizeEqualToSize(self.intrinsicContentSize, CGSizeMake(UIViewNoIntrinsicMetric , UIViewNoIntrinsicMetric)))
    {
#if TARGET_OS_IPHONE
        [description appendFormat:@"Content size...%@", NSStringFromCGSize(self.intrinsicContentSize)];
#else
        [description appendFormat:@"Content size...%@", NSStringFromSize(self.intrinsicContentSize)];
#endif
        
#if TARGET_OS_IPHONE
        // Add content mode, but only for iOS
        if ((self.intrinsicContentSize.width > 0) ||
            (self.intrinsicContentSize.height > 0))
            [description appendFormat:@" [Content Mode: %@]", [View nameForContentMode:self.contentMode]];
#endif
        [description appendFormat:@"\n"];
    }

#if BOOK_EXAMPLE == 0
    // Alignment rect
    if (!CGRectEqualToRect(self.frame, [self alignmentRectForFrame:self.frame]))
        [description appendFormat:@"Align't rect...%@\n", self.readableAlignmentRect];
    
    // Edge insets
    if ((self.alignmentRectInsets.top != 0) ||
        (self.alignmentRectInsets.left != 0) ||
        (self.alignmentRectInsets.bottom != 0) ||
        (self.alignmentRectInsets.right != 0))
        [description appendFormat:@"Align Insets...%@\n", self.readableAlignmentInsets];
    
#if TARGET_OS_IPHONE
    if ([self isKindOfClass:[UILabel class]])
        [description appendFormat:@"PrefMaxWidth:..%0.2f\n", [(UILabel *)self preferredMaxLayoutWidth]];
#elif TARGET_OS_MAC
    if ([self isKindOfClass:[NSTextField class]])
        [description appendFormat:@"PrefMaxWidth:..%0.2f\n", [(NSTextField *)self preferredMaxLayoutWidth]];
#endif
#endif
    
    // Content Hugging
    [description appendFormat:@"Hugging........[H %d] [V %d]\n", (int) HugValueH(self), (int) HugValueV(self)];
    
    // Compression Resistance
     [description appendFormat:@"Resistance.....[H %d] [V %d]\n", (int) ResistValueH(self), (int) ResistValueV(self)];

    // Constraint Count
    [description appendFormat:@"Constraints....%d\n", (int) self.constraints.count];
    
#if BOOK_EXAMPLE == 0
    // Referencing views
    NSDictionary *participating = [self participatingViews];
    [description appendFormat:@"View Refs......%d\n", (int) participating.allKeys.count];
    for (NSString *string in participating.allKeys)
        [description appendFormat:@"     <%@>\n", string];
    
    // Organize constraints
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        // removed nametag support here
        NSString *key = @"Constraints";
        
        NSArray *array = dict[key];
        if (array)
            array = [array arrayByAddingObject:constraint];
        else
            array = @[constraint];
        dict[key] = array;
    }
    
    NSArray *sortedKeys = [dict.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    
    // Enumerate constraints
    for (NSString *key in sortedKeys)
    {
        NSArray *constraints = dict[key];
        int i = 1;
        
        [description appendFormat:@"\n\"%@\"\n", key];
        for (NSLayoutConstraint *constraint in constraints)
        {
            BOOL isLayoutConstraint = [constraint.class isEqual:[NSLayoutConstraint class]];
            
            // List each constraint
            [description appendFormat:@"%2d. ", i++];
            
            // Display priority only for layout constraints
            if (isLayoutConstraint)
                [description appendFormat:@"@%4d ", (int) constraint.priority];
            
            // Show constraint
            [description appendFormat:@"%@", constraint.stringValue];
            
            // Add non-standard classes
            if (!isLayoutConstraint)
            {
                [description appendFormat:@" (%@", constraint.class.description];
                
                // This seems to be nonsense -- Refer to the content hugging
                // or compression resistance priority properties instead
                // [description appendFormat:@", %d", (int) constraint.priority];
                
                [description appendString:@")"];
            }
            [description appendFormat:@"\n"];
            
            // If format is available, show that
            if (constraint.visualFormat)
                [description appendFormat:@"     Format: %@\n", constraint.visualFormat];
            
            // Show description ???
            [description appendFormat:    @"     Descr: %@\n", constraint.description];
        }
    }
    
    // Referencing Constraints
    [description appendFormat:@"\n"];
    
    NSArray *references = self.constraintReferences;
    if (references.count)
        [description appendString:@"Other Constraint References to View\n"];
    
    int i = 1;
    for (NSLayoutConstraint *constraint in references)
    {
        View *firstView = (View *) constraint.firstItem;
        View *secondView = (View *) constraint.secondItem;

        // List each likely owner (guaranteed if install)
        View *nca = [firstView nearestCommonAncestorWithView:secondView];
        if (!nca) continue;

        // List each constraint
        [description appendFormat:@"%2d. ", i++];
        
        // Owner
        [description appendFormat:@"<%@> : ", nca.objectIdentifier];

        // Priority
        [description appendFormat:@"@%4d ", (int) constraint.priority];
        
        // Show constraint
        [description appendFormat:@"%@", constraint.stringValue];
        
        [description appendString:@"\n"];
    }
    
#else
    
    int i = 1;
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        BOOL isLayoutConstraint = [constraint.class isEqual:[NSLayoutConstraint class]];
        
        // List each constraint
        [description appendFormat:@"%2d. ", i++];
        
        // Display priority only for layout constraints
        if (isLayoutConstraint)
            [description appendFormat:@"@%4d ", (int) constraint.priority];
        
        // Show constraint
        [description appendFormat:@"%@", constraint.stringValue];
        
        // Add non-standard classes
        if (!isLayoutConstraint)
            [description appendFormat:@" (%@)", constraint.class.description];

        [description appendFormat:@"\n"];
    }
#endif
    
    return description;
}

- (NSArray *) skippableClasses
{
#if TARGET_OS_IPHONE
    return @[
             [UIButton class], [UILabel class], [UISwitch class],
             [UIStepper class], [UITextField class], // [UIScrollView class],
             [UIActivityIndicatorView class],
             [UIAlertView class], [UIPickerView class],
             [UIProgressView class], [UIPageControl class],
             [UIToolbar class], [UINavigationBar class],
             [UISearchBar class], [UITabBar class],
             [UISlider class], [UIImageView class],
             ];
#elif TARGET_OS_MAC
    return @[
             ];
#endif
}

- (void) showViewReport: (BOOL) descend
{
    printf("\nVIEW REPORT %s\n", self.viewLayoutDescription.UTF8String);
    
    if (!descend)
        return;
    
    for (Class class in [self skippableClasses])
        if ([self isKindOfClass:class])
            return;
    
    for (View *view in self.subviews)
        [view showViewReport: descend];
}

- (void) generateViewReportForUser: (NSString *) userName
{
    NSString *destination = [NSString stringWithFormat:@"/Users/%@/Desktop/AutoLayoutViewReport.txt", userName];
    
    freopen(destination.UTF8String, "w+", stdout);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterLongStyle;

    printf("Auto Layout View Report\n  %s\n", [formatter stringFromDate:[NSDate date]].description.UTF8String);
    [self showViewReport:YES];
    fclose(stdout);
    NSLog(@"Written to %@", destination);
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#if OVERRIDE_SAFETY
// Swap ignored to error if you need warning

// DEBUG ONLY. Do not ship with this code
- (void) testAmbiguity
{
    NSLog(@"<%@:0x%0x>: %@", self.class.description, (int)self, self.hasAmbiguousLayout ? @"Ambiguous" : @"Unambiguous");
    
    for (View *view in self.subviews)
        [view testAmbiguity];
}


// DEBUG ONLY. For somewhat obvious reasons, do not ship with this code
- (NSString *) trace
{
    return [self.window performSelector:@selector(_autolayoutTrace)];
}
#endif
#pragma GCC diagnostic pop
@end

// Cleanup
#undef View
