/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <Foundation/Foundation.h>
#import "Utility.h"

#define POSITIONING_NAME    @"Dragging Position Constraint"
#define DRAG_START_NOTIFICATION_NAME     @"Started Drag"
#define DRAG_END_NOTIFICATION_NAME       @"Finished Drag"
#define DOUBLE_TAP_NOTIFICATION_NAME     @"Draggable View Double Tap"

@interface DraggableView : UIView
+ (instancetype) view;
+ (instancetype) randomView;

+ (NSArray *) originatedPositionNames;
@property (nonatomic, strong) NSArray *competingPositionNames;

- (void) enableDragging: (BOOL) yorn;
- (void) moveToPosition: (CGPoint) position;
@end