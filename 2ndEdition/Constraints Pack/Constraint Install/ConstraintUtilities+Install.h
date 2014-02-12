/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#if TARGET_OS_IPHONE
@import Foundation;
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#endif

#pragma mark - Cross Platform
#if TARGET_OS_IPHONE
    @import UIKit;
#ifndef VIEW_CLASS
    #define VIEW_CLASS UIView
#endif
#ifndef COLOR_CLASS
    #define COLOR_CLASS UIColor
#endif
#elif TARGET_OS_MAC
#ifndef VIEW_CLASS
    #define VIEW_CLASS NSView
#endif
#ifndef COLOR_CLASS
    #define COLOR_CLASS NSColor
#endif
#endif

// Custom install priorities built around iOS and OS X values
typedef enum
{
    LayoutPriorityRequired = 1000,
    LayoutPriorityHigh = 750,
    LayoutPriorityDragResizingWindow = 510,
    LayoutPriorityMedium = 501,
    LayoutPriorityFixedWindowSize = 500,
    LayoutPriorityLow = 250,
    LayoutPriorityFittingSize = 50,
    LayoutPriorityMildSuggestion = 1,
} ConstraintLayoutPriority;

// Sources for contraints
typedef enum
{
    ConstraintSourceTypeUnknown = 0,
    ConstraintSourceTypeCustom,          // User defined
    ConstraintSourceTypeInferred,        // IB created from static placement
    ConstraintSourceTypeDisambiguation,  // IB created for ambiguous items
    ConstraintSourceTypeSatisfaction,    // IB created via suggested constraints
    
} ConstraintSourceType;


// A few items for my convenience
#define AQUA_SPACE  8
#define AQUA_INDENT 20
#define PREPCONSTRAINTS(VIEW) [VIEW setTranslatesAutoresizingMaskIntoConstraints:NO]

// Install and remove arrays of constraints created by visual formats
void InstallConstraints(NSArray *constraints, NSUInteger priority, NSString *nametag);
void InstallConstraint(NSLayoutConstraint *constraint, NSUInteger priority, NSString *nametag);
void RemoveConstraints(NSArray *constraints);

// Retrieve IB-generated constraints from a view controller root
NSArray *ConstraintsSourcedFromIB(NSArray *constraints);

// If you use in production code, please make sure to add
// namespace indicators to class category methods

// Find nearest common ancestor
@interface VIEW_CLASS (HierarchySupport)
@property (nonatomic, readonly) NSArray *superviews;
@property (nonatomic, readonly) NSArray *allSubviews;
- (BOOL) isAncestorOfView: (VIEW_CLASS *) aView;
- (VIEW_CLASS *) nearestCommonAncestorToView: (VIEW_CLASS *) aView;
@end

// Convenience
@interface VIEW_CLASS (ConstraintReadyViews)
+ (instancetype) view;
@end

// Access items in a friendlier manner
@interface NSLayoutConstraint (ViewHierarchy)
@property (nonatomic, readonly) VIEW_CLASS *firstView;
@property (nonatomic, readonly) VIEW_CLASS *secondView;
@property (nonatomic, readonly) BOOL isUnary;
@property (nonatomic, readonly) VIEW_CLASS *likelyOwner;
@property (nonatomic, readonly) ConstraintSourceType sourceType;
@end

// Install and remove constraints to and from their natural location
@interface NSLayoutConstraint (SelfInstall)
- (BOOL) install;
- (BOOL) install: (float) priority;
- (void) remove;
@end