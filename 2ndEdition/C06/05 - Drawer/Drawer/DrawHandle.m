/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "DrawHandle.h"
#import "DrawerView.h"
#import "Utility.h"

@implementation DrawHandle
{
    float yOffset;
    DrawerView __weak *_drawer;
}

#pragma mark - Build View
- (instancetype) initWithDrawer: (UIView *) theDrawer
{
    self = [super initWithFrame:CGRectMake(0, 0, 60, 60)];
    if (!self) return self;
    
    // Weakly store reference to drawer
    _drawer = (DrawerView *) theDrawer;
    
    // Create edged aqua circle
    self.backgroundColor = AQUA_COLOR;
    self.layer.cornerRadius = 30;
    self.layer.borderWidth = 4;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    
    // Add Double Tap Recognizer
    UITapGestureRecognizer *dtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    dtap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:dtap];
    
    return self;
}

+ (instancetype) handleWithDrawer: (UIView *) drawer
{
    DrawHandle *handle = [[self alloc] initWithDrawer: (UIView *) drawer];
    return handle;
}

#pragma mark - Gesture Recognition

- (void) doubleTap: (UITapGestureRecognizer *) tgr
{
    
    if (tgr.state == UIGestureRecognizerStateRecognized)
    {
        NSLayoutConstraint *constraint;
        constraint = [self constraintNamed:DRAWER_POSITION_NAME];
        if (!constraint)
        {
            constraint = [NSLayoutConstraint constraintWithItem:_drawer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_drawer.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:-_drawer.drawerHeight];
            constraint.nametag = DRAWER_POSITION_NAME;
            [constraint install:600];
        }
        
        [UIView animateWithDuration:0.2f animations:^{
            if (constraint.constant == -_drawer.drawerHeight)
                constraint.constant = 0;
            else
                constraint.constant = -_drawer.drawerHeight;
            [constraint.likelyOwner.window layoutIfNeeded];
        }];
    }
}

#pragma mark - Direct Drag

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Store offset
    UITouch *touch = [touches anyObject];
    yOffset = [touch locationInView:self].y - (self.bounds.size.height / 2.0f);
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Handle Drag
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.superview];
    CGFloat dy = self.superview.superview.bounds.size.height - (touchPoint.y - yOffset);
    
    NSLayoutConstraint *constraint = [self constraintNamed:DRAWER_POSITION_NAME];
    if (!constraint)
    {
        constraint = [NSLayoutConstraint constraintWithItem:_drawer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_drawer.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:-dy];
        constraint.nametag = DRAWER_POSITION_NAME;
        [constraint install:600];
    }
    constraint.constant = -dy;
    [constraint.likelyOwner setNeedsLayout];
}
@end

