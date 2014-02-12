/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#if TARGET_OS_IPHONE
@import Foundation;
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#endif

#import "ConstraintUtilities+Install.h"

/*
 
 All this was built primarily in lockstep with book development
 If you find anything here you can use, go for it. All standard warnings apply.

 */

// Utility
NSLayoutAttribute AttributeForAlignment(NSLayoutFormatOptions alignment);
BOOL ConstraintIsHorizontal(NSLayoutConstraint *constraint);

// Build and Install
NSArray *VisualConstraints(NSString *format, NSLayoutFormatOptions options, NSDictionary *metrics, NSDictionary *bindings, NSUInteger fallbackPriority);
void AddVisualConstraints(NSString *format, NSLayoutFormatOptions options, NSDictionary *metrics, NSDictionary *bindings, NSUInteger fallbackPriority, NSString *name);

// Constrain within the view's superview
void ConstrainToSuperview(VIEW_CLASS *view, NSUInteger priority);
void SizeAndConstrainToSuperview(VIEW_CLASS *view, float side, NSUInteger  priority);

// Stretching
void StretchToSuperview(VIEW_CLASS *view, CGFloat indent, NSUInteger priority);
void StretchHorizontallyToSuperview(VIEW_CLASS *view, CGFloat indent, NSUInteger priority);
void StretchVerticallyToSuperview(VIEW_CLASS *view, CGFloat indent, NSUInteger priority);

// Sizing
void ConstrainViewSize(VIEW_CLASS *view, CGSize size, NSUInteger priority);
void ConstrainMinimumViewSize(VIEW_CLASS *view, CGSize size, NSUInteger priority);
void ConstrainMaximumViewSize(VIEW_CLASS *view, CGSize size, NSUInteger priority);

// Matching
void MatchSizeH(VIEW_CLASS *view1, VIEW_CLASS *view2, NSUInteger priority);
void MatchSizeV(VIEW_CLASS *view1, VIEW_CLASS *view2, NSUInteger priority);
void MatchSize(VIEW_CLASS *view1, VIEW_CLASS *view2, NSUInteger priority);
void MatchSizesH(NSArray *views, NSUInteger priority);
void MatchSizesV(NSArray *views, NSUInteger priority);


// Rows and Columns
void BuildLineWithSpacing(NSArray *views, NSLayoutFormatOptions alignment, NSString *spacing, NSUInteger priority);
void BuildLine(NSArray *views, NSLayoutFormatOptions alignment, NSUInteger priority);
void PseudoDistributeWithSpacers(VIEW_CLASS *superview, NSArray *views, NSLayoutFormatOptions alignment, NSUInteger priority);
void PseudoDistributeCenters(NSArray *views, NSLayoutFormatOptions alignment, NSUInteger priority);

// Floating
void FloatViewsH(VIEW_CLASS *firstView, VIEW_CLASS *lastView, NSUInteger priority);
void FloatViewsV(VIEW_CLASS *firstView, VIEW_CLASS *lastView, NSUInteger priority);

// Alignment
void AlignView(VIEW_CLASS *view, NSLayoutAttribute attribute, NSInteger inset, NSUInteger priority);
void CenterView(VIEW_CLASS *view, NSUInteger priority);
void CenterViewH(VIEW_CLASS *view, NSUInteger priority);
void CenterViewV(VIEW_CLASS *view, NSUInteger priority);

// Position
NSLayoutConstraint *ConstraintPositioningViewH(VIEW_CLASS *view, CGFloat x);
NSLayoutConstraint *ConstraintPositioningViewV(VIEW_CLASS *view, CGFloat y);
NSArray *ConstraintsPositioningView(VIEW_CLASS *view, CGPoint point);
void PositionView(VIEW_CLASS *view, CGPoint point, NSUInteger priority);

// Apply format for view
void Pin(VIEW_CLASS *view, NSString *format);
void PinWithPriority(VIEW_CLASS *view, NSString *format, NSString *name, int priority);

// Contrast View
void LoadContrastViewsOntoView(VIEW_CLASS *aView);
