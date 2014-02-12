/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#if TARGET_OS_IPHONE
@import Foundation;
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#endif

// A nametag is an associated string object that can be assigned to any object.
// Similar in intent and nature to UIView/NSView's "tag" property, it allows you to
// assign readable text to objects for annotation and searching.

// If you use in production code, please make sure to add
// namespace indicators to class category methods

@interface NSObject (Nametags)
@property (nonatomic, strong) NSString *nametag;
@end

