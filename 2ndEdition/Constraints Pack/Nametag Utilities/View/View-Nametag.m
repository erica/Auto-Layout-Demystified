/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "NametagUtilities.h"

#pragma mark - Named Views
@implementation VIEW_CLASS (Nametags)
// All tags in use
- (NSArray *) nametags
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (constraint.nametag && ![array containsObject:constraint.nametag])
            [array addObject:constraint.nametag];
    }
    
    return array;
}

// First matching view
- (VIEW_CLASS *) viewWithNametag: (NSString *) aName
{
    if (!aName) return nil;
    
    // Is this the right view?
    if ([self.nametag isEqualToString:aName])
        return self;
    
    // Recurse depth first on subviews
    for (VIEW_CLASS *subview in self.subviews)
    {
        VIEW_CLASS *resultView = [subview viewNamed:aName];
        if (resultView) return resultView;
    }
    
    // Not found
    return nil;
}

// All matching views
- (NSArray *) viewsWithNametag: (NSString *) aName
{
    if (!aName) return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    if ([self.nametag isEqualToString:aName])
        [array addObject:self];
    
    // Recurse depth first on subviews
    for (VIEW_CLASS *subview in self.subviews)
    {
        NSArray *results = [subview viewsNamed:aName];
        if (results && results.count)
            [array addObjectsFromArray:results];
    }
    
    return array;
}

// First matching view
- (VIEW_CLASS *) viewNamed: (NSString *) aName
{
    if (!aName) return nil;
    return [self viewWithNametag:aName];
}

// All matching views
- (NSArray *) viewsNamed: (NSString *) aName
{
    if (!aName) return nil;
    return [self viewsWithNametag:aName];
}
@end

#pragma mark - Description

@implementation VIEW_CLASS (DescriptionUtility)

// Simple Apple-style frame
- (NSString *) readableFrame
{
    return [NSString stringWithFormat:@"(%d %d; %d %d)" , (int) self.frame.origin.x, (int) self.frame.origin.y, (int) self.frame.size.width, (int) self.frame.size.height];
}

// Recursively travel down the view tree, increasing the indentation level for children
- (void) dumpView: (VIEW_CLASS *) aView atIndent: (int) indent into:(NSMutableString *) outstring
{
    for (int i = 0; i < indent; i++)
        [outstring appendString:@"--"];
    [outstring appendFormat:@"[%2d] <%@>", indent, aView.objectIdentifier];
    if (aView.nametag)
        [outstring appendFormat:@" [%@]", aView.nametag];
    [outstring appendFormat:@" %@" , aView.readableFrame];
    [outstring appendString:@"\n"];
    for (VIEW_CLASS *view in aView.subviews)
        [self dumpView:view atIndent:indent + 1 into:outstring];
}

// Start the tree recursion at level 0 with the root view
- (NSString *) viewTree
{
    NSMutableString *outstring = [NSMutableString string];
    [outstring appendString:@"\n"];
    [self dumpView:self atIndent:0 into:outstring];
    return outstring;
}

/*
 NOTE ON OS X:  NSView method _subtreeDescription
 */

@end
