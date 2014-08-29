//
//  DurationBlock.h
//  HelloWorld
//
//  Created by Erica Sadun on 11/17/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnimationBlock)(void);

@interface DurationBlock : NSObject
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, copy) AnimationBlock block;
@property (nonatomic) NSInteger tag;
+ (instancetype) block;
@end
