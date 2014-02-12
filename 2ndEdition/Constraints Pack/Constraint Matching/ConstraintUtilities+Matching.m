/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "ConstraintUtilities+Matching.h"
#import "NametagUtilities.h"

#pragma mark - Named Constraint Support
@implementation VIEW_CLASS (NamedConstraintSupport)

// Returns first constraint with matching name
// Type not checked
- (NSLayoutConstraint *) constraintNamed: (NSString *) aName
{
    if (!aName) return nil;
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.nametag && [constraint.nametag isEqualToString:aName])
            return constraint;

    // Recurse up the tree
    if (self.superview)
        return [self.superview constraintNamed:aName];

    return nil;
}

// Returns first constraint with matching name and view.
// Type not checked
- (NSLayoutConstraint *) constraintNamed: (NSString *) aName matchingView: (VIEW_CLASS *) theView
{
    if (!aName) return nil;
    
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.nametag && [constraint.nametag isEqualToString:aName])
        {
            if (constraint.firstItem == theView)
                return constraint;
            if (constraint.secondItem && (constraint.secondItem == theView))
                return constraint;
        }
    
    // Recurse up the tree
    if (self.superview)
        return [self.superview constraintNamed:aName matchingView:theView];
    
    return nil;
}

// Returns all matching constraints
// Type not checked
- (NSArray *) constraintsNamed: (NSString *) aName
{
    // For this, all constraints match a nil item
    if (!aName) return self.constraints;
    
    // However, constraints have to have a name to match a non-nil name
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.nametag && [constraint.nametag isEqualToString:aName])
            [array addObject:constraint];
    
    // recurse upwards
    if (self.superview)
        [array addObjectsFromArray:[self.superview constraintsNamed:aName]];
    
    return array;
}

// Returns all matching constraints specific to a given view
// Type not checked
- (NSArray *) constraintsNamed: (NSString *) aName matchingView: (VIEW_CLASS *) theView
{
    // For this, all constraints match a nil item
    if (!aName) return self.constraints;
    
    // However, constraints have to have a name to match a non-nil name
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.nametag && [constraint.nametag isEqualToString:aName])
        {
            if (constraint.firstItem == theView)
                [array addObject:constraint];
            else if (constraint.secondItem && (constraint.secondItem == theView))
                [array addObject:constraint];
        }
    
    // recurse upwards
    if (self.superview)
        [array addObjectsFromArray:[self.superview constraintsNamed:aName matchingView:theView]];

    return array;
}
@end

#pragma mark - Constraint Matching
@implementation NSLayoutConstraint (ConstraintMatching)

// This ignores any priority, looking only at y (R) mx + b
- (BOOL) isEqualToLayoutConstraint: (NSLayoutConstraint *) constraint
{
    // I'm still wavering on these two checks
    if (![self.class isEqual:[NSLayoutConstraint class]]) return NO;
    if (![self.class isEqual:constraint.class]) return NO;
    
    // Compare properties
    if (self.firstItem != constraint.firstItem) return NO;
    if (self.secondItem != constraint.secondItem) return NO;
    if (self.firstAttribute != constraint.firstAttribute) return NO;
    if (self.secondAttribute != constraint.secondAttribute) return NO;
    if (self.relation != constraint.relation) return NO;
    if (self.multiplier != constraint.multiplier) return NO;
    if (self.constant != constraint.constant) return NO;
    
    return YES;
}

// This looks at priority too
- (BOOL) isEqualToLayoutConstraintConsideringPriority:(NSLayoutConstraint *)constraint
{
    if (![self isEqualToLayoutConstraint:constraint])
        return NO;
    
    return (self.priority == constraint.priority);
}

- (BOOL) refersToView: (VIEW_CLASS *) theView
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

- (BOOL) isHorizontal
{
    return IS_HORIZONTAL_ATTRIBUTE(self.firstAttribute);
}
@end

#pragma mark - Managing Matching Constraints
@implementation VIEW_CLASS (ConstraintMatching)

// Find first matching constraint. (Priority, Archiving ignored)
- (NSLayoutConstraint *) constraintMatchingConstraint: (NSLayoutConstraint *) aConstraint
{
    NSArray *views = [@[self] arrayByAddingObjectsFromArray:self.superviews];
    for (VIEW_CLASS *view in views)
        for (NSLayoutConstraint *constraint in view.constraints)
            if ([constraint isEqualToLayoutConstraint:aConstraint])
                return constraint;

    return nil;
}


// Return all constraints from self and subviews
// Call on self.window for the entire collection
- (NSArray *) allConstraints
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.constraints];
    for (VIEW_CLASS *view in self.subviews)
        [array addObjectsFromArray:[view allConstraints]];
    return array;
}

// Ancestor constraints pointing to self
- (NSArray *) referencingConstraintsInSuperviews
{
    NSMutableArray *array = [NSMutableArray array];
    for (VIEW_CLASS *view in self.superviews)
    {
        for (NSLayoutConstraint *constraint in view.constraints)
        {
            if (![constraint.class isEqual:[NSLayoutConstraint class]])
                continue;
            
            if ([constraint refersToView:self])
                [array addObject:constraint];
        }
    }
    return array;
}

// Ancestor *and* self constraints pointing to self
- (NSArray *) referencingConstraints
{
    NSMutableArray *array = [self.referencingConstraintsInSuperviews mutableCopy];
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (![constraint.class isEqual:[NSLayoutConstraint class]])
            continue;
        
        if ([constraint refersToView:self])
            [array addObject:constraint];
    }
    return array;
}

// Find all matching constraints. (Priority, archiving ignored)
// Use with arrays returned by format strings to find installed versions
- (NSArray *) constraintsMatchingConstraints: (NSArray *) constraints
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in constraints)
    {
        NSLayoutConstraint *match = [self constraintMatchingConstraint:constraint];
        if (match)
            [array addObject:match];
    }
    return array;
}

// All constraints matching view in this ascent
// See also: referencingConstraints and referencingConstraintsInSuperviews
- (NSArray *) constraintsReferencingView: (VIEW_CLASS *) theView
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *views = [@[self] arrayByAddingObjectsFromArray:self.superviews];

    for (VIEW_CLASS *view in views)
        for (NSLayoutConstraint *constraint in view.constraints)
        {
            if (![constraint.class isEqual:[NSLayoutConstraint class]])
                continue;
            
            if ([constraint refersToView:theView])
                [array addObject:constraint];
        }
    
    return array;
}

- (NSArray *) constraintsReferencingView: (VIEW_CLASS *) firstView andView: (VIEW_CLASS *) secondView
{
    NSArray *firstArray = [self constraintsReferencingView:firstView];

    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in firstArray)
    {
        if ([constraint refersToView:secondView])
            [array addObject:constraint];
    }

    return array;
}

// IB-sourced Constraints
- (NSArray *) IBSourcedConstraintsReferencingView: (VIEW_CLASS *) theView
{
    return ConstraintsSourcedFromIB([self constraintsReferencingView:theView]);
}

// Remove constraint
- (void) removeMatchingConstraint: (NSLayoutConstraint *) aConstraint
{
    NSLayoutConstraint *match = [self constraintMatchingConstraint:aConstraint];
    if (match)
        [match remove];
}

// Remove constraints
// Use for removing constraings generated by format
- (void) removeMatchingConstraints: (NSArray *) anArray
{
    for (NSLayoutConstraint *constraint in anArray)
        [self removeMatchingConstraint:constraint];
}

// Remove constraints via name
- (void) removeConstraintsNamed: (NSString *) name
{
    NSArray *array = [self constraintsNamed:name];
    for (NSLayoutConstraint *constraint in array)
        [constraint remove];
}

// Remove named constraints matching view
- (void) removeConstraintsNamed: (NSString *) name matchingView: (VIEW_CLASS *) theView
{
    NSArray *array = [self constraintsNamed:name matchingView:theView];
    for (NSLayoutConstraint *constraint in array)
        [constraint remove];
}

// Width and height constraints are always installed to self

// Constraints affecting view width
- (NSArray *) widthConstraints
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeWidth)
            [array addObject:constraint];
        
        if (constraint.firstItem != self) continue;
        if (constraint.secondItem != self) continue;
        if (
             ((constraint.firstAttribute == NSLayoutAttributeLeading) &&
              (constraint.secondAttribute == NSLayoutAttributeTrailing))
             ||
             ((constraint.firstAttribute == NSLayoutAttributeLeft) &&
              (constraint.secondAttribute == NSLayoutAttributeRight))
             ||
             ((constraint.firstAttribute == NSLayoutAttributeTrailing) &&
              (constraint.secondAttribute == NSLayoutAttributeLeading))
             ||
             ((constraint.firstAttribute == NSLayoutAttributeRight) &&
              (constraint.secondAttribute == NSLayoutAttributeLeft))
            ) [array addObject:constraint];
    }
    
    return array;
}

// Constraints affecting view height
- (NSArray *) heightConstraints
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeHeight)
            [array addObject:constraint];

        if (constraint.firstItem != self) continue;
        if (constraint.secondItem != self) continue;
        if (
            ((constraint.firstAttribute == NSLayoutAttributeTop) &&
             (constraint.secondAttribute == NSLayoutAttributeBottom))
            ||
            ((constraint.firstAttribute == NSLayoutAttributeBottom) &&
             (constraint.secondAttribute == NSLayoutAttributeTop))
            ) [array addObject:constraint];
    }
    
    return array;
}
@end

