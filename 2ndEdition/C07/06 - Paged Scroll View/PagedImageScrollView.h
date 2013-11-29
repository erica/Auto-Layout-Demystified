/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import <UIKit/UIKit.h>

@interface AutoLayoutScrollView : UIScrollView
@property (nonatomic, readonly) UIView *customContentView;
@end

@interface PagedImageScrollView : AutoLayoutScrollView
- (void) addView: (UIView *) view;
@property (nonatomic, assign) int pageNumber;
@end
