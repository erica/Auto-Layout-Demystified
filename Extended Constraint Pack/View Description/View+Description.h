/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <Foundation/Foundation.h>
// Compatibility
#if TARGET_OS_IPHONE
#define View UIView
#elif TARGET_OS_MAC
#define View NSView
#endif

#pragma mark - Description

@interface View (DescriptionUtility)
@property (nonatomic, readonly) NSString *readableFrame;
@property (nonatomic, readonly) NSString *objectIdentifier;
- (NSString *) viewTree;
@end


// Cleanup
#undef View
