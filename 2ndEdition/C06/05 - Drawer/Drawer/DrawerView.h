/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import <UIKit/UIKit.h>
#import "DrawHandle.h"

// Constraint group names
#define LINE_BUILDING_NAME      @"Build Line"
#define MINMAX_NAME             @"MinMax Positions"

// Holder acts as a drawer that stores views
@interface DrawerView : UIView
+ (instancetype) holderWithDrawerHeight: (CGFloat) height;
+ (NSArray *) originatedPositionNames;

@property (nonatomic, retain) NSArray *competingPositionNames;
@property (nonatomic, strong) UIView *handle;
@property (nonatomic, assign) CGFloat drawerHeight;

// View management
- (void) removeView: (UIView *) view;
- (void) addView: (UIView *) view;
- (BOOL) managesViewLayout: (UIView *) view;
@end
