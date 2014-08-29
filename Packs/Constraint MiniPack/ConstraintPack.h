/*
 
 Erica Sadun, http://ericasadun.com
 
 See iOS Auto Layout Demystified
 
 */

/*
 CROSS PLATFORM
 Allow constraint utilities to work cross-platform
 */

@import Foundation;
#if TARGET_OS_IPHONE
    @import UIKit;
#else
    @import Cocoa;
    @import AppKit;
#endif

// Compatibility
#if TARGET_OS_IPHONE
    #define View UIView
    #define Color UIColor
    #define Image UIImage
    #define Font UIFont
#elif TARGET_OS_MAC
    #define View NSView
    #define Color NSColor
    #define Image NSImage
    #define Font NSFont
#endif

/*
 CONVENIENCE CONSTANTS
 */
#define AquaSpace       8
#define AquaIndent      20
#define SkipConstraint  (CGRectNull.origin.x)

/*
 UTILITY
 */
View *NearestCommonViewAncestor(View *view1, View *view2);

/*
 SELF-INSTALLING CONSTRAINTS
 Constraints install to their natural destination
 Self-install is not needed in iOS 8 and later
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
- (void) dumpViewReport;
@end

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

/*
 PLACEMENT
 */
void ConstrainViewToSuperview(View *view, CGFloat inset, NSUInteger priority);
void PlaceViewInSuperview(View *view, NSString *position, CGFloat inseth, CGFloat insetv, CGFloat priority);
#if TARGET_OS_IPHONE
void PlaceView(UIViewController *controller, UIView *view, NSString *position, CGFloat inseth, CGFloat insetv, CGFloat priority);
#endif
void AddConstraint(NSString *request, View *view1, View * view2, CGFloat m, CGFloat c, NSInteger priority);

// Cleanup
#undef View
#undef Color
#undef Image
#undef Font

