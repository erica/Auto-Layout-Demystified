/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import "NSObject-Nametag.h"
@import ObjectiveC;

@implementation NSObject (Nametags)
- (id) nametag
{
    return objc_getAssociatedObject(self, @selector(nametag));
}

- (void) setNametag: (NSString *) nametag
{
    objc_setAssociatedObject(self, @selector(nametag), nametag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end