//
//  LockControl.h
//  HelloWorld
//
//  Created by Erica Sadun on 2/4/13.
//  Copyright (c) 2013 Erica Sadun. All rights reserved.
//

@class LockControl;

#import <Foundation/Foundation.h>
@protocol LockOwner <NSObject>
- (void) lockDidUpdate: (LockControl *) sender;
@end

@interface LockControl : UIControl
@property (nonatomic, readonly, assign) BOOL value;
+ (id) controlWithTarget: (id <LockOwner>) target;
@end
