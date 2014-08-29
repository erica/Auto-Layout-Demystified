/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import <UIKit/UIKit.h>

@interface PagedImageScrollView : UIScrollView
- (void) addView: (UIView *) view;
@property (nonatomic, readonly) UIView *pagedContentView;
@property (nonatomic, assign) int pageNumber;
@end
