/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <Foundation/Foundation.h>
#import "Utility.h"

@interface TestView : VIEW_CLASS
+ (instancetype) view;
+ (instancetype) randomView;
- (void) enableDragging: (BOOL) yorn;
- (void) moveToPosition: (CGPoint) position;
@end