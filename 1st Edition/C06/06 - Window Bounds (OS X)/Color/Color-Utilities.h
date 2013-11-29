/*
 
 Color utils
 Erica Sadun
 
 */

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
    #define COLOR_CLASS UIColor
#elif TARGET_OS_MAC
    #define COLOR_CLASS NSColor
#endif

// Random color
COLOR_CLASS *randomColor();

// Custom Colors for my own use
#if TARGET_OS_IPHONE
    #define ORANGE_COLOR    [UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f]
    #define AQUA_COLOR      [UIColor colorWithRed:0.0f green:.6745 blue:.8039 alpha:1.0f]
    #define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#elif TARGET_OS_MAC
    #define ORANGE_COLOR    [NSColor colorWithDeviceRed:1 green:0.6 blue:0 alpha:1]
    #define AQUA_COLOR    [NSColor colorWithDeviceRed:0 green:0.6745 blue:0.8039 alpha:1]
    #define COOKBOOK_PURPLE_COLOR [NSColor colorWithDeviceRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#endif

// NSView Background color
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
@interface NSView (OSXBGColorExtension)
@property (nonatomic, weak) NSColor *backgroundColor;
@end
#endif

