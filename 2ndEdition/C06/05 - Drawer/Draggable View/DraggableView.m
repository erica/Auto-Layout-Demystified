/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "DraggableView.h"
#import <QuartzCore/QuartzCore.h>
#import "Color-Utilities.h"

#pragma mark - Utilities
@implementation DraggableView
{
    CGPoint touchPoint;
    CGPoint origin;
    BOOL allowDragging;
}

#pragma mark - Creation

+ (instancetype) view
{
    DraggableView *view = [[self alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

+ (instancetype) randomView
{
    DraggableView *view = [self view];
    view.backgroundColor = randomColor();
    return view;
}

#pragma mark - Movement Request

+ (NSArray *) originatedPositionNames
{
    return @[POSITIONING_NAME];
}

- (void) moveToPosition: (CGPoint) position
{
    NSArray *array;
    
    // Remove previous location for view
    array = [self.superview constraintsNamed:POSITIONING_NAME matchingView:self];
    for (NSLayoutConstraint *constraint in array)
        [constraint remove];
    
    // Remove participation from competing position groups
    for (NSString *name in _competingPositionNames)
    {
        array = [self.superview constraintsNamed:name matchingView:self];
        for (NSLayoutConstraint *constraint in array)
            [constraint remove];
    }
    
    // Create new constraints and add them
    array = constraintsPositioningView(self, position);
    for (NSLayoutConstraint *constraint in array)
    {
        constraint.nametag =  POSITIONING_NAME;
        [constraint install:LayoutPriorityFixedWindowSize + 1];
    }
}

#pragma mark - Dragging

// Install recognizers
- (void) enableDragging: (BOOL) yorn
{
    self.gestureRecognizers = @[];
    self.userInteractionEnabled = yorn;

    if (yorn)
    {
        // Dragging
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:panRecognizer];

        // Double Tap
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        tgr.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tgr];
    }
}

- (void) notify: (NSString *) name
{
    if (!name) return;
    NSNotification *note = [NSNotification notificationWithName:name object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void) handleDoubleTap: (UITapGestureRecognizer *) tgr
{
    if (tgr.state == UIGestureRecognizerStateRecognized)
        [self notify:DOUBLE_TAP_NOTIFICATION_NAME];
}

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
    // Store offset and announce drag
    if (uigr.state == UIGestureRecognizerStateBegan)
    {
        origin = self.frame.origin;
        [self notify:DRAG_START_NOTIFICATION_NAME];
    }

    // Perform movement
    CGPoint translation = [uigr translationInView:self.superview];
    CGPoint destination = CGPointMake(origin.x + translation.x, origin.y + translation.y);
    [self moveToPosition:destination];
    
    // Check for end / announcement
    if (uigr.state == UIGestureRecognizerStateEnded)
        [self notify:DRAG_END_NOTIFICATION_NAME];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // Test for dragging
    if (self.gestureRecognizers.count)
        [self.superview bringSubviewToFront:self];
}
@end
