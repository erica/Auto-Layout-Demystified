/*
 
 Color utils
 Erica Sadun
 
 */

#import "Color-Utilities.h"

// Return a random platform-specific color
COLOR_CLASS *randomColor()
{
    COLOR_CLASS *theColor;
    
#if TARGET_OS_IPHONE
    theColor = [UIColor colorWithRed:((random() % 255) / 255.0f) green:((random() % 255) / 255.0f) blue:((random() % 255) / 255.0f) alpha:1.0f];
#elif TARGET_OS_MAC
    theColor = [NSColor colorWithDeviceRed:((random() % 255) / 255.0f) green:((random() % 255) / 255.0f) blue:((random() % 255) / 255.0f) alpha:1.0f];
#endif
    
    return theColor;
}

// Expand NSView to have a background color
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
@implementation NSView (OSXBGColorExtension)
- (NSColor *) backgroundColor
{
    CGColorRef colorRef = self.layer.backgroundColor;
    NSColor *theColor = [NSColor colorWithCGColor:colorRef];
    return theColor;
}

- (void) setBackgroundColor:(NSColor *)backgroundColor
{
    [self setWantsLayer:YES];
    self.layer.backgroundColor = backgroundColor.CGColor;
}
@end
#endif
