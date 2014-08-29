/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import Foundation;
// Compatibility
#if TARGET_OS_IPHONE
@import UIKit;
#define View UIView
#elif TARGET_OS_MAC
@import AppKit;
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
