/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "ConstraintUtilities-Install.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
void InstallConstraints(NSArray *constraints, NSUInteger priority, NSString *nametag)
{
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (![constraint isKindOfClass:[NSLayoutConstraint class]])
            continue;
        if (priority)
            [constraint install:priority];
        else
            [constraint install];
        
        if ([constraint respondsToSelector:@selector(setNametag:)])
        {
            [constraint performSelector:@selector(setNametag:) withObject:nametag];
        }
    }
}

void InstallConstraint(NSLayoutConstraint *constraint, NSUInteger priority, NSString *nametag)
{
    InstallConstraints(@[constraint], priority, nametag);
}
#pragma GCC diagnostic pop

void RemoveConstraints(NSArray *constraints)
{
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (![constraint isKindOfClass:[NSLayoutConstraint class]])
            continue;
        [constraint remove];
    }
}

NSArray *ConstraintsSourcedFromIB(NSArray *constraints)
{
    NSMutableArray *results = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (constraint.shouldBeArchived)
            [results addObject:constraint];
    }
    return results;
}

#pragma mark - Views

#pragma mark - Hierarchy
@implementation VIEW_CLASS (HierarchySupport)

// Return an array of all superviews
- (NSArray *) superviews
{
    NSMutableArray *array = [NSMutableArray array];
    VIEW_CLASS *view = self.superview;
    while (view)
    {
        [array addObject:view];
        view = view.superview;
    }
    
    return array;
}

// Return an array of all subviews
- (NSArray *) allSubviews
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (VIEW_CLASS *view in self.subviews)
    {
        [array addObject:view];
        [array addObjectsFromArray:[view allSubviews]];
    }
    
    return array;
}

// Test if the current view has a superview relationship to a view
- (BOOL) isAncestorOf: (VIEW_CLASS *) aView
{
    return [aView.superviews containsObject:self];
}

// Return the nearest common ancestor between self and another view
- (VIEW_CLASS *) nearestCommonAncestor: (VIEW_CLASS *) aView
{
    // Check for same view
    if (self == aView)
        return self;
    
    // Check for direct superview relationship
    if ([self isAncestorOf:aView])
        return self;
    if ([aView isAncestorOf:self])
        return aView;
    
    // Search for indirect common ancestor
    NSArray *ancestors = self.superviews;
    for (VIEW_CLASS *view in aView.superviews)
        if ([ancestors containsObject:view])
            return view;
    
    // No common ancestor
    return nil;
}
@end

#pragma mark - Constraint-Ready Views
@implementation VIEW_CLASS (ConstraintReadyViews)
+ (instancetype) view
{
    VIEW_CLASS *newView = [[VIEW_CLASS alloc] initWithFrame:CGRectZero];
    newView.translatesAutoresizingMaskIntoConstraints = NO;
    return newView;
}
@end

#pragma mark - NSLayoutConstraint

#pragma mark - View Hierarchy
@implementation NSLayoutConstraint (ViewHierarchy)
// Cast the first item to a view
- (VIEW_CLASS *) firstView
{
    return self.firstItem;
}

// Cast the second item to a view
- (VIEW_CLASS *) secondView
{
    return self.secondItem;
}

// Are two items involved or not
- (BOOL) isUnary
{
    return self.secondItem == nil;
}

// Return NCA
- (VIEW_CLASS *) likelyOwner
{
    if (self.isUnary)
        return self.firstView;
    
    return [self.firstView nearestCommonAncestor:self.secondView];
}


/*
 From NSLayoutConstraint.h:
 
 When a view is archived, it archives some but not all constraints in its -constraints array.  The value of shouldBeArchived informs UIView if a particular constraint should be archived by UIView / NSView. If a constraint is created at runtime in response to the state of the object, it isn't appropriate to archive the constraint - rather you archive the state that gives rise to the constraint.  Since the majority of constraints that should be archived are created in Interface Builder (which is smart enough to set this prop to YES), the default value for this property is NO.
 */

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
@end

#pragma mark - Self Install
@implementation NSLayoutConstraint (SelfInstall)
- (BOOL) install
{
    // Handle Unary constraint
    if (self.isUnary)
    {
        // Add weak owner reference
        [self.firstView addConstraint:self];
        return YES;
    }
    
    // Install onto nearest common ancestor
    VIEW_CLASS *view = [self.firstView nearestCommonAncestor:self.secondView];
    if (!view)
    {
        NSLog(@"Error: Constraint cannot be installed. No common ancestor between items.");
        return NO;
    }
    
    [view addConstraint:self];    
    return YES;
}

// Set priority and install
- (BOOL) install: (float) priority
{
    self.priority = priority;
    return [self install];
}

- (void) remove
{
    if (![self.class isEqual:[NSLayoutConstraint class]])
    {
        NSLog(@"Error: Can only uninstall NSLayoutConstraint. %@ is an invalid class.", self.class.description);
        return;
    }
    
    if (self.isUnary)
    {
        VIEW_CLASS *view = self.firstView;
        [view removeConstraint:self];
        return;
    }
    
    // Remove from preferred recipient
    VIEW_CLASS *view = [self.firstView nearestCommonAncestor:self.secondView];
    if (!view) return;
    
    // If the constraint not on view, this is a no-op
    [view removeConstraint:self];
}
@end