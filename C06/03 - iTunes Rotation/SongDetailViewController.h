/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <UIKit/UIKit.h>

@interface SongDetailViewController : UIViewController
@property (nonatomic, strong) NSDictionary *record;
+ (instancetype) controllerWithData: (NSDictionary *) record;
@end
