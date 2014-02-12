/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#if TARGET_OS_IPHONE
@import Foundation;
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#endif

#ifndef VIEW_CLASS
#if TARGET_OS_IPHONE
    @import UIKit;
    #define VIEW_CLASS UIView
    #define COLOR_CLASS UIColor
    #define IMAGE_CLASS UIImage
#elif TARGET_OS_MAC
    #define VIEW_CLASS NSView
    #define COLOR_CLASS NSColor
    #define IMAGE_CLASS NSImage
#endif
#endif

// If you use in production code, please make sure to add
// namespace indicators to class category methods

/*
 
 Named Views
 Adds support for naming views (with nametags vs numeric number tags)
 and retrieving views by name
 
 */

#pragma mark - Named View Support
@interface VIEW_CLASS (Nametags)
@property (nonatomic, readonly) NSArray *nametags;
- (VIEW_CLASS *) viewNamed: (NSString *) aName;
- (NSArray *) viewsNamed: (NSString *) aName;
@end

/*
 
 View Description
 Dump a view tree and provide handy descriptive labels
 for debugging
 
 */

#pragma mark - Description

@interface VIEW_CLASS (DescriptionUtility)
@property (nonatomic, readonly) NSString *readableFrame;
- (NSString *) viewTree;
@end
