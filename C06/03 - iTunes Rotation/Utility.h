/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark - Cross Platform
#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
    #define VIEW_CLASS UIView
    #define COLOR_CLASS UIColor
    #define IMAGE_CLASS UIImage
#elif TARGET_OS_MAC
    #define VIEW_CLASS NSView
    #define COLOR_CLASS NSColor
    #define IMAGE_CLASS NSImage
#endif

// Constraint Installation
#import "ConstraintUtilities-Install.h"

// Prebuilt Functions, Macros, Etc
#import "ConstraintUtilities-Layout.h"
#import "Constraints.h"
#import "Constraints-CreationMacros.h"

// Constraint Matching, Retrieval
#import "NSObject-Nametag.h"
#import "ConstraintUtilities-Matching.h"

// Constraint Description for Debugging
#import "NSObject-Description.h"
#import "ConstraintUtilities-Description.h"

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

// Other utilities
#if TARGET_OS_IPHONE
    #define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    #define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    #define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#elif TARGET_OS_MAC

#endif