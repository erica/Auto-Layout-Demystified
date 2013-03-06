/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <UIKit/UIKit.h>

// Constraint Group Names
#define DRAWER_POSITION_NAME    @"TopPosition"

// Handle manages touches for opening and closing the drawer
@interface DrawHandle : UIView
+ (instancetype) handleWithDrawer: (UIView *) drawer;
@end
