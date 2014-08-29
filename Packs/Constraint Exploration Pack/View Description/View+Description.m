/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "View+Description.h"

#if TARGET_OS_IPHONE
#define View UIView
#elif TARGET_OS_MAC
#define View NSView
#endif

#pragma mark - Description

@implementation View (DescriptionUtility)
// Return 'Class description : hex memory address'
- (NSString *) objectIdentifier
{
    return [NSString stringWithFormat:@"%@:0x%0x", self.class.description, (int) self];
}

// Simple Apple-style frame
- (NSString *) readableFrame
{
    return [NSString stringWithFormat:@"(%d %d; %d %d)" , (int) self.frame.origin.x, (int) self.frame.origin.y, (int) self.frame.size.width, (int) self.frame.size.height];
}

// Recursively travel down the view tree, increasing the indentation level for children
- (void) dumpView: (View *) aView atIndent: (int) indent into:(NSMutableString *) outstring
{
    for (int i = 0; i < indent; i++)
        [outstring appendString:@"--"];
    [outstring appendFormat:@"[%2d] <%@>", indent, aView.objectIdentifier];
    [outstring appendFormat:@" %@" , aView.readableFrame];
    [outstring appendString:@"\n"];
    for (View *view in aView.subviews)
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

// Cleanup
#undef View

