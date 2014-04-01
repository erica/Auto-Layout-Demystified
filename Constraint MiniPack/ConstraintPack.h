/*
 
 Erica Sadun, http://ericasadun.com
 
 See iOS Auto Layout Demystified
 
 */

/*
 CROSS PLATFORM
 Allow constraint utilities to work cross-platform
 */

// Imports
#if TARGET_OS_IPHONE
    @import UIKit;
    @import Foundation;
#elif TARGET_OS_MAC
    #import <Foundation/Foundation.h>
#endif

// Compatibility aliases
#ifndef  COMPATIBILITY_ALIASES_DEFINED
#if TARGET_OS_IPHONE
    @compatibility_alias View UIView;
    @compatibility_alias Color UIColor;
    @compatibility_alias Image UIImage;
#elif TARGET_OS_MAC
    @compatibility_alias View NSView;
    @compatibility_alias Color NSColor;
    @compatibility_alias Image NSImage;
#endif
#endif
#define COMPATIBILITY_ALIASES_DEFINED

/*
 CONVENIENCE CONSTANTS
 */
#define AquaSpace       8
#define AquaIndent      20
#define SkipConstraint  (CGRectNull.origin.x)

/*
 SELF-INSTALLING CONSTRAINTS
 Constraints install to their natural destination
 */
@interface NSLayoutConstraint (ConstraintPack)
- (BOOL) install;
- (BOOL) installWithPriority: (float) priority;
- (void) remove;
- (BOOL) refersToView: (View *) theView;
@end

/*
 ARRAY INSTALLATION FUNCTIONS
 */
void InstallConstraints(NSArray *constraints, NSUInteger priority);
void RemoveConstraints(NSArray *constraints);

/*
 CONSTRAINT REFERENCES
 */
@interface View (ConstraintPack)
@property (nonatomic, readonly) NSArray *externalConstraintReferences;
@property (nonatomic, readonly) NSArray *internalConstraintReferences;
@property (nonatomic, readonly) NSArray *constraintReferences;
@property (nonatomic) BOOL autoLayoutEnabled;
- (View *) nearestCommonAncestorWithView: (View *) view;
@end

/*
 DEBUGGING
 */
// Keep view within superview
void ConstrainViewToSuperview(View *view, CGFloat inset, NSUInteger priority);

/*
 SINGLE VIEW LAYOUT
 */

// Sizing
void SizeView(View *view, CGSize size, NSUInteger  priority);
void ConstrainMinimumViewSize(View *view, CGSize size,  NSUInteger priority);
void ConstrainMaximumViewSize(View *view, CGSize size,  NSUInteger  priority);

// Positioning
void PositionView(View *view, CGPoint point, NSUInteger priority);

// Stretching
void StretchViewToSuperview(View *view, CGSize inset, NSUInteger priority);
void StretchViewHorizontallyToSuperview(View *view, CGFloat inset, NSUInteger priority);
void StretchViewVerticallyToSuperview(View *view, CGFloat inset, NSUInteger priority);

// Centering
void CenterViewInSuperview(View *view, BOOL horizontal, BOOL vertical, NSUInteger priority);

// Aligning
void AlignViewInSuperview(View *view, NSLayoutAttribute attribute, NSInteger inset, NSUInteger priority);

/*
 VIEW TO VIEW LAYOUT
 */
void AlignViews(NSUInteger priority, View *view1, View *view2, NSLayoutAttribute attribute);
void ConstrainViewArray(NSUInteger priority, NSString *formatString, NSArray *viewArray); // Use view1, view2, view3... to match array order
void ConstrainViewsWithBinding(NSUInteger priority, NSString *formatString, NSDictionary *bindings);
#define ConstrainViews(_priority_, _formatString_, ...) ConstrainViewsWithBinding(_priority_, _formatString_, NSDictionaryOfVariableBindings(__VA_ARGS__))

/*
 LAYOUT GUIDES
 */
#if TARGET_OS_IPHONE
void StretchViewToTopLayoutGuide(UIViewController *controller, View *view, NSInteger inset, NSUInteger priority);
void StretchViewToBottomLayoutGuide(UIViewController *controller, View *view, NSInteger inset, NSUInteger priority);
void StretchViewToController(UIViewController *controller, View *view, CGSize inset, NSUInteger priority);
@interface UIViewController (ExtendedLayouts)
@property (nonatomic) BOOL extendLayoutUnderBars;
@end
#endif

/*
 CONTENT SIZE
 */
void SetHuggingPriority(View *view, NSUInteger priority);
void SetResistancePriority(View *view, NSUInteger priority);

/*
 LIVING IN A NON-CONSTRAINT WORLD
 */
#if TARGET_OS_IPHONE
void LayoutThenCleanup(View *view, void(^layoutBlock)());
#endif

