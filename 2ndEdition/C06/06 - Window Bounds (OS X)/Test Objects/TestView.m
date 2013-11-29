/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "TestView.h"
#import <QuartzCore/QuartzCore.h>
#import "Color-Utilities.h"

#pragma mark - Utilities
@implementation TestView
{
    CGPoint touchPoint;
    CGPoint origin;
    BOOL allowDragging;
}

#pragma mark - Creation
+ (instancetype) view
{
    TestView *view = [[self alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

+ (instancetype) randomView
{
    TestView *view = [self view];
    view.backgroundColor = randomColor();
    return view;
}

- (void) moveToPosition: (CGPoint) position
{
    NSArray *array;
    
    // Remove previous location for view
    array = [self.superview constraintsNamed:@"Dragging Position Constraint" matchingView:self];
    for (NSLayoutConstraint *constraint in array)
        [constraint remove];
        
    // Create new constraints and add them
    array = constraintsPositioningView(self, position);

    // To avoid win resizing, lower the priority
    for (NSLayoutConstraint *constraint in array)
    {
        constraint.nametag =  @"Dragging Position Constraint";
        [constraint install:LayoutPriorityFixedWindowSize + 1];
    }
}

#pragma mark - Dragging

#if TARGET_OS_IPHONE
- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
    if (uigr.state == UIGestureRecognizerStateBegan)
        origin = self.frame.origin;    
    
    CGPoint translation = [uigr translationInView:self.superview];
    CGPoint destination = CGPointMake(origin.x + translation.x, origin.y + translation.y);
    
    [self moveToPosition:destination];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (self.gestureRecognizers.count)
        [self.superview bringSubviewToFront:self];
}

- (void) enableDragging: (BOOL) yorn
{
    if (yorn)
    {
        self.userInteractionEnabled = YES;
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.gestureRecognizers = @[panRecognizer];
        return;
    }
    
    self.gestureRecognizers = @[];
}

#elif TARGET_OS_MAC
- (void) enableDragging: (BOOL) yorn
{
    allowDragging = yorn;
}

- (void) mouseDown: (NSEvent *) event
{
    if (!allowDragging) return;
    touchPoint = [event locationInWindow];
    origin = self.frame.origin;

    // Bring subview to front
    [self.superview addSubview:self positioned:NSWindowAbove relativeTo:nil];
}

- (void) mouseDragged:(NSEvent *) event
{
    if (!allowDragging) return;

    CGPoint pt = [event locationInWindow];
    CGFloat dx = pt.x - touchPoint.x;
    CGFloat dy = pt.y - touchPoint.y;
    
    // Move to the destination point
    CGPoint destination = CGPointMake(origin.x + dx, (self.superview.frame.size.height - self.frame.size.height) - (origin.y + dy));
    [self moveToPosition:destination];
}

- (void) mouseUp: (NSEvent *) event
{
    if (!allowDragging) return;
    touchPoint = CGPointZero;
}
#endif
@end
