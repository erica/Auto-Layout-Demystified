//
//  AppDelegate.m
//  TestProject
//
//  Created by Erica Sadun on 12/24/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import "AppDelegate.h"
#import "Utility.h"
#import "TestView.h"
#import "ConstraintUtilities-Description.h"

@implementation AppDelegate
{
    NSMutableArray *views;
}

- (void) addViews: (NSInteger) howMany
{
    views = [NSMutableArray array];
    
    for (int i = 0; i < howMany; i++)
    {
        TestView *view = [TestView randomView];
        [self.view addSubview:view];
        [views addObject:view];
        
        view.wantsLayer = YES;
        view.layer.cornerRadius = 16;
        view.layer.borderWidth = 4;
        view.layer.borderColor = [NSColor blackColor].CGColor;
        
        NSString *name = [NSString stringWithFormat:@"View %d", i + 1];        
        view.nametag = name;
        constrainToSuperview(view, 100, LayoutPriorityRequired);
        [view enableDragging:YES];
        [view moveToPosition:CGPointMake(40 * i, 40 * i)];
    }
}

- (IBAction)fanViews:(id)sender
{
    [NSAnimationContext beginGrouping];
    NSAnimationContext.currentContext.duration = 0.3f;
    for (int i = 0; i < views.count; i++)
    {
        NSArray *constraints = [self.view constraintsNamed:@"Dragging Position Constraint" matchingView:views[i]];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint.animator setConstant:40 * i];
    }
    [NSAnimationContext endGrouping];
}

- (IBAction)stackViews:(id)sender
{
    [NSAnimationContext beginGrouping];
    NSAnimationContext.currentContext.duration = 0.3f;
    for (int i = 0; i < views.count; i++)
    {
        NSArray *constraints = [self.view constraintsNamed:@"Dragging Position Constraint" matchingView:views[i]];
        for (NSLayoutConstraint *constraint in constraints)
        {
            CGFloat c = IS_HORIZONTAL_ATTRIBUTE(constraint.firstAttribute) ? 0 : 100 * i;
            [constraint.animator setConstant:c];
        }
    }
    [NSAnimationContext endGrouping];
}

- (void) awakeFromNib
{
    _view = _window.contentView;

    srandom((unsigned int)time(0));
    [self addViews:4];
    
    // Request zero content size at a fixed window priority
    // TestViews will override this
    constrainViewSize(_view, CGSizeMake(0, 0), NSLayoutPriorityWindowSizeStayPut);
    
    // Provide a "minimum" view size, by requesting an exact
    // size at a fairly low priority for no-view scenarios
    constrainViewSize(_view, CGSizeMake(100, 100), 100);
}

- (IBAction)listConstraints:(id)sender
{
    // [self.view listConstraints];
    [self.view showViewReport:YES];
}

- (IBAction)viewConstraints:(id)sender
{
    [_window visualizeConstraints:[self.view allConstraints]];
}

@end
