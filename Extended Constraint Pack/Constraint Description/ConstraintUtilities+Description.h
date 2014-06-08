/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import Foundation;
@import QuartzCore;

#import "ConstraintPack.h"

#if TARGET_OS_IPHONE
#define View UIView
#elif TARGET_OS_MAC
#define View NSView
#endif

// Sources for contraints
typedef enum
{
    ConstraintSourceTypeUnknown = 0,
    ConstraintSourceTypeCustom,          // User defined
    ConstraintSourceTypeInferred,        // IB created from static placement
    ConstraintSourceTypeDisambiguation,  // IB created for ambiguous items
    ConstraintSourceTypeSatisfaction,    // IB created via suggested constraints
    
} ConstraintSourceType;

#define IsSizeAttribute(ATTRIBUTE) [@[@(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight)] containsObject:@(ATTRIBUTE)]
#define IsCenterAttribute(ATTRIBUTE) [@[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY)] containsObject:@(ATTRIBUTE)]
#define IsEdgeAttribute(ATTRIBUTE) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]
#define IsLocationAttribute(ATTRIBUTE) (IsEdgeAttribute(ATTRIBUTE) || IsCenterAttribute(ATTRIBUTE))

#define IsHorizontalAttribute(ATTRIBUTE) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeCenterX), @(NSLayoutAttributeWidth)] containsObject:@(ATTRIBUTE)]
#define IsVerticalAttribute(ATTRIBUTE) [@[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeCenterY), @(NSLayoutAttributeHeight), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]

#define IsHorizontalAlignment(ALIGNMENT) [@[@(NSLayoutFormatAlignAllLeft), @(NSLayoutFormatAlignAllRight), @(NSLayoutFormatAlignAllLeading), @(NSLayoutFormatAlignAllTrailing), @(NSLayoutFormatAlignAllCenterX), ] containsObject:@(ALIGNMENT)]
#define IsVerticalAlignment(ALIGNMENT) [@[@(NSLayoutFormatAlignAllTop), @(NSLayoutFormatAlignAllBottom), @(NSLayoutFormatAlignAllCenterY), @(NSLayoutFormatAlignAllBaseline), ] containsObject:@(ALIGNMENT)]


/*
 
 Description Category -- Supports debugging.
 Not for real-world deployment. Please use these with care.
 
 */

// Retrieving Hug and Resistance values cross-platform
#if TARGET_OS_IPHONE
    #define HugValueH(VIEW) [VIEW contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal]
    #define HugValueV(VIEW) [VIEW contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical]
    #define ResistValueH(VIEW) [VIEW contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal]
    #define ResistValueV(VIEW) [VIEW contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical]
#elif TARGET_OS_MAC
    #define HugValueH(VIEW) [VIEW contentHuggingPriorityForOrientation:NSLayoutConstraintOrientationHorizontal]
    #define HugValueV(VIEW) [VIEW contentHuggingPriorityForOrientation:NSLayoutConstraintOrientationVertical]
    #define ResistValueH(VIEW) [VIEW contentCompressionResistancePriorityForOrientation:NSLayoutConstraintOrientationHorizontal]
    #define ResistValueV(VIEW) [VIEW contentCompressionResistancePriorityForOrientation:NSLayoutConstraintOrientationVertical]
#endif

#define ReadableRect(_aRect_) [NSString stringWithFormat:@"(%d %d; %d %d)" , (int) (_aRect_).origin.x, (int) (_aRect_).origin.y, (int) (_aRect_).size.width, (int) (_aRect_).size.height]
#define ReadableInsets(_insets_) [NSString stringWithFormat:@"[t:%d, l:%d, b:%d, r:%d]", (int) _insets_.top, (int) _insets_.left, (int) _insets_.bottom, (int) _insets_.right]


/*
 STRING DESCRIPTION
 Produces an item.attribute Relation m * item.attribute + b description
 of the constraint in question
 */

@interface NSLayoutConstraint (StringDescription)
+ (NSString *) nameForLayoutAttribute: (NSLayoutAttribute) anAttribute;
+ (NSString *) nameForFormatOption: (NSLayoutFormatOptions) anOption;
+ (NSString *) nameForLayoutRelation: (NSLayoutRelation) aRelation;
@property (nonatomic, readonly) NSString *stringValue;
@end

/*
 VISUAL FORMAT
 Apple-style + a few minor additions
 */

@interface NSLayoutConstraint (FormatDescription)
@property (nonatomic, readonly) NSString *visualFormat;
@end

/*
 CODE DESCRIPTION
 From constraint to code. For books.
 */

@interface NSLayoutConstraint (CodeDescription)
+ (NSString *) codeNameForLayoutAttribute: (NSLayoutAttribute) anAttribute;
+ (NSString *) codeNameForLayoutRelation: (NSLayoutRelation) aRelation;
- (NSString *) codeDescriptionWithBindings: (NSDictionary *) dict;
@property (nonatomic, readonly) NSString *codeDescription;
@end

/*
 CONSTRAINT VIEW UTILITY
 Readable representations for descriptions
 */

@interface View (ConstraintUtility)
- (NSString *) readableFrame;
- (NSString *) readableAlignmentInsets;
- (NSString *) readableAlignmentRect;
@end

/*
 FUNCTIONALITY DESCRIPTION
 Add role descriptions that explain what each constraint does
 */

@interface NSLayoutConstraint (SelfDescription)
// Describe the role of the constraint, suitable for auto-naming
@property (nonatomic, readonly) NSString *constraintDescription;
@end

/*
 VIEW DESCRIPTION
 Explain all view features
 */

#define OVERRIDE_SAFETY 0

@interface View (Description)

#if TARGET_OS_IPHONE
+ (NSString *) nameForContentMode: (UIViewContentMode) mode;
#endif

@property (nonatomic, readonly) NSString *viewLayoutDescription;
@property (nonatomic, readonly) NSString *superviewsDescription;

- (void) listConstraints;
- (void) listAllConstraints;
- (void) showViewReport: (BOOL) descend;
- (void) generateViewReportForUser: (NSString *) userName;

#if OVERRIDE_SAFETY
@property (nonatomic, readonly) NSString *trace;
- (void) testAmbiguity;
#endif
@end

// Cleanup
#undef View